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
    @AppStorage("useGridView") private var useGridView: Bool = false

    init(viewModel: LibraryViewModel = LibraryViewModel(bookRepository: RealmBookRepository())) {
        self.viewModel = viewModel
    }

    var sortedBooks: [Book] {
        let sortedBooks: [Book]
        switch sortCriteria {
        case "Title":
            sortedBooks = viewModel.books.sorted { isAscending ? $0.title < $1.title : $0.title > $1.title }
        case "Author":
            sortedBooks = viewModel.books.sorted { isAscending ? $0.author < $1.author : $0.author > $1.author }
        case "Year":
            sortedBooks = viewModel.books.sorted { isAscending ? $0.year < $1.year : $0.year > $1.year }
        default:
            sortedBooks = viewModel.books
        }
        return sortedBooks
    }

    var filteredBooks: [Book] {
        if searchText.isEmpty {
            return sortedBooks
        } else {
            return sortedBooks.filter { $0.title.lowercased().contains(searchText.lowercased()) }
        }
    }

    var body: some View {
        VStack {
            HStack {
                Text("My Library")
                    .font(.largeTitle)
                    .bold()
                Spacer()
                Button(action: {
                    withAnimation {
                        isSortingVisible.toggle()
                    }
                }) {
                    Image(systemName: "arrow.up.arrow.down")
                        .imageScale(.large)
                }
                .padding(.trailing, 10)
                Button(action: {
                    withAnimation {
                        isSearchBarVisible.toggle()
                    }
                }) {
                    Image(systemName: "magnifyingglass")
                        .imageScale(.large)
                }
                .padding(.trailing, 10)
                NavigationLink(destination: AddBookView(viewModel: viewModel)) {
                    Image(systemName: "plus")
                        .imageScale(.large)
                }
                .padding(.trailing)
            }
            .padding([.leading, .trailing, .top])

            if isSearchBarVisible {
                SearchBarView(text: $searchText)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }

            if isSortingVisible {
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
                .transition(.move(edge: .top).combined(with: .opacity))
            }

            if isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .scaleEffect(1.5, anchor: .center)
                    .padding()
            }

            if useGridView {
                BookGridItems(filteredBooks: filteredBooks, viewModel: viewModel, refreshBooks: refreshBooks, confirmDelete: confirmDelete)
            } else {
                BookListItems(filteredBooks: filteredBooks, viewModel: viewModel, refreshBooks: refreshBooks, confirmDelete: confirmDelete)
            }
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
    }

    func refreshBooks() {
        isLoading = true
        DispatchQueue.global().async {
            let books = viewModel.bookRepository.fetchBooks()
            DispatchQueue.main.async {
                viewModel.books = books
                isLoading = false
            }
        }
    }

    func confirmDelete(at offsets: IndexSet) {
        for index in offsets {
            let book = filteredBooks[index]
            if let bookIndex = viewModel.books.firstIndex(where: { $0.id == book.id }) {
                bookToDelete = viewModel.books[bookIndex]
                showingAlert = true
            }
        }
    }
}

struct BookListView_Previews: PreviewProvider {
    static var previews: some View {
        BookListView(viewModel: LibraryViewModel(bookRepository: InMemoryRepository()))
    }
}
