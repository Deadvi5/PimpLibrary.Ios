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

            List {
                ForEach(filteredBooks) { book in
                    NavigationLink(destination: BookDetailView(viewModel: viewModel, book: book)) {
                        HStack {
                            if !book.coverImageUrl.isEmpty {
                                if let url = URL(string: book.coverImageUrl) {
                                    AsyncImage(url: url)
                                        .frame(width: 50, height: 75)
                                        .cornerRadius(5)
                                        .aspectRatio(contentMode: .fit)
                                }
                            } else {
                                Rectangle()
                                    .fill(Color.gray)
                                    .frame(width: 50, height: 75)
                                    .cornerRadius(5)
                            }
                            VStack(alignment: .leading) {
                                Text(book.title)
                                    .font(.headline)
                                Text(book.author)
                                    .font(.subheadline)
                                Text(book.genre)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text(book.year)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.leading, 8)
                        }
                        .padding(.vertical, 8)
                    }
                }
                .onDelete(perform: confirmDelete)
            }
            .listStyle(InsetGroupedListStyle())
            .refreshable {
                refreshBooks()
            }
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
        .navigationBarHidden(true)
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
        if let index = offsets.first {
            bookToDelete = viewModel.books[index]
            showingAlert = true
        }
    }
}

struct BookListView_Previews: PreviewProvider {
    static var previews: some View {
        BookListView(viewModel: LibraryViewModel(bookRepository: InMemoryRepository()))
    }
}
