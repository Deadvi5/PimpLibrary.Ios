import SwiftUI

struct BookListView: View {
    @ObservedObject var viewModel: LibraryViewModel
    @State private var showingAlert = false
    @State private var bookToDelete: Book?
    @State private var searchText = ""
    @State private var isSearchBarVisible = false
    @State private var isSortingVisible = false
    @State private var sortCriteria = "Title"
    @State private var isAscending = true
    @State private var isLoading = false
    @State private var textOffset: CGFloat = -UIScreen.main.bounds.width
    @State private var textOpacity: Double = 0.0
    // Use AppStorage to track grid view setting (default: false)
    @AppStorage("useGridView") private var useGridView: Bool = false
    
    // Inizializzazione con view model di default
    init(viewModel: LibraryViewModel = LibraryViewModel(bookRepository: RealmBookRepository())) {
        self.viewModel = viewModel
    }
    
    // Libri ordinati e filtrati
    var sortedBooks: [Book] {
        sortBooks(books: viewModel.books, by: sortCriteria, ascending: isAscending)
    }
    
    var filteredBooks: [Book] {
        filterBooks(books: sortedBooks, by: searchText)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            headerView
                .background(Color(.systemBackground).shadow(radius: 2))
            if isSearchBarVisible {
                SearchBarView(text: $searchText)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
            if isSortingVisible {
                sortingOptionsView
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
            if isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .scaleEffect(1.5)
                    .padding()
            }
            // Mostra la lista o la griglia a seconda della preferenza (using the local @AppStorage property)
            Group {
                if useGridView {
                    BookGridItems(filteredBooks: filteredBooks,
                                  viewModel: viewModel,
                                  refreshBooks: refreshBooks,
                                  confirmDelete: confirmDelete(at:),
                                  isLoading: isLoading)
                } else {
                    BookListItems(filteredBooks: filteredBooks,
                                  viewModel: viewModel,
                                  refreshBooks: refreshBooks,
                                  confirmDelete: confirmDelete(at:))
                }
            }
            .background(Color(.systemGroupedBackground))
        }
        .navigationBarHidden(true)
        .alert(isPresented: $showingAlert) {
            Alert(
                title: Text("Delete Book"),
                message: Text("Are you sure you want to delete \(bookToDelete?.title ?? "")?"),
                primaryButton: .destructive(Text("Delete")) {
                    if let book = bookToDelete {
                        viewModel.removeBook(book: book)
                    }
                },
                secondaryButton: .cancel()
            )
        }
        .onAppear {
            animateTextEntrance()
        }
    }
    
    // Header con titolo e bottoni per refresh, ordinamento, ricerca e aggiunta
    private var headerView: some View {
        HStack {
            Text("PimpLibrary")
                .font(.system(size: 32, weight: .bold))
                .offset(x: textOffset)
                .opacity(textOpacity)
            Spacer()
            Button(action: { updateBooks() }) {
                Image(systemName: "arrow.clockwise")
                    .imageScale(.large)
                    .padding(8)
            }
            Button(action: { withAnimation { isSortingVisible.toggle() } }) {
                Image(systemName: "arrow.up.arrow.down")
                    .imageScale(.large)
                    .padding(8)
            }
            Button(action: { withAnimation { isSearchBarVisible.toggle() } }) {
                Image(systemName: "magnifyingglass")
                    .imageScale(.large)
                    .padding(8)
            }
            NavigationLink(destination: AddBookView(viewModel: viewModel)) {
                Image(systemName: "plus")
                    .imageScale(.large)
                    .padding(8)
            }
        }
        .padding([.leading, .trailing, .top])
    }
    
    // Vista per le opzioni di ordinamento
    private var sortingOptionsView: some View {
        HStack {
            Picker("Sort by", selection: $sortCriteria) {
                Text("Title").tag("Title")
                Text("Author").tag("Author")
                Text("Year").tag("Year")
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal)
            
            Toggle(isOn: $isAscending) {
                Text(isAscending ? "Ascending" : "Descending")
            }
            .padding(.horizontal)
        }
    }
    
    // Ordinamento dei libri
    private func sortBooks(books: [Book], by criteria: String, ascending: Bool) -> [Book] {
        switch criteria {
        case "Title":
            return books.sorted {
                ascending ? $0.title.lowercased() < $1.title.lowercased()
                          : $0.title.lowercased() > $1.title.lowercased()
            }
        case "Author":
            return books.sorted {
                ascending ? $0.author.lowercased() < $1.author.lowercased()
                          : $0.author.lowercased() > $1.author.lowercased()
            }
        case "Genre":
            return books.sorted {
                ascending ? $0.genre.lowercased() < $1.genre.lowercased()
                          : $0.genre.lowercased() > $1.genre.lowercased()
            }
        case "Year":
            return books.sorted {
                ascending ? $0.year < $1.year : $0.year > $1.year
            }
        case "Last Added":
            return ascending ? books : books.reversed()
        default:
            return books
        }
    }

    
    // Filtraggio in base al testo di ricerca
    private func filterBooks(books: [Book], by searchText: String) -> [Book] {
        if searchText.isEmpty { return books }
        return books.filter { $0.title.lowercased().contains(searchText.lowercased()) }
    }
    
    // Refresh dei libri dal repository
    private func refreshBooks() {
        isLoading = true
        DispatchQueue.global().async {
            let books = viewModel.bookRepository.fetchBooks()
            DispatchQueue.main.async {
                viewModel.books = books
                isLoading = false
            }
        }
    }
    
    // Conferma cancellazione
    private func confirmDelete(at offsets: IndexSet) {
        for index in offsets {
            let book = filteredBooks[index]
            if let bookIndex = viewModel.books.firstIndex(where: { $0.id == book.id }) {
                bookToDelete = viewModel.books[bookIndex]
                showingAlert = true
            }
        }
    }
    
    // Animazione di entrata del titolo
    private func animateTextEntrance() {
        withAnimation(Animation.easeInOut(duration: 1.0)) {
            textOffset = 0
            textOpacity = 1.0
        }
    }
    
    // Aggiornamento dei libri tramite il servizio API (default OpenLibrary)
    private func updateBooks() {
        guard !viewModel.books.isEmpty else { return }
        isLoading = true
        let group = DispatchGroup()
        // Seleziona il servizio API in base al valore nelle Settings
        let selectedAPI = UserDefaults.standard.string(forKey: "selectedAPI") ?? "Open Library"
        let isbnService: IsbnService = (selectedAPI == "Google Books") ? GoogleBookIsbnService() : OpenLibraryIsbnService()
        
        for (index, book) in viewModel.books.enumerated() {
            // Se il libro ha un ISBN (non vuoto)
            guard !book.isbn.isEmpty else { continue }
            group.enter()
            isbnService.fetchBookDetails(isbn: book.isbn) { result in
                switch result {
                case .success(let updatedBook):
                    DispatchQueue.main.async {
                        // Preserva il progresso di lettura
                        let mergedBook = Book(
                            id: book.id,
                            isbn: book.isbn,
                            title: updatedBook.title,
                            author: updatedBook.author,
                            year: updatedBook.year,
                            description: updatedBook.description,
                            genre: updatedBook.genre,
                            coverImageUrl: updatedBook.coverImageUrl,
                            coverImageData: updatedBook.coverImageData,
                            currentPage: book.currentPage,
                            totalPages: updatedBook.totalPages
                        )
                        viewModel.books[index] = mergedBook
                    }
                case .failure(let error):
                    print("Errore aggiornando il libro: \(error.localizedDescription)")
                }
                group.leave()
            }
        }
        group.notify(queue: .main) {
            isLoading = false
        }
    }
}

struct BookListView_Previews: PreviewProvider {
    static var previews: some View {
        BookListView(viewModel: LibraryViewModel(bookRepository: InMemoryRepository()))
    }
}
