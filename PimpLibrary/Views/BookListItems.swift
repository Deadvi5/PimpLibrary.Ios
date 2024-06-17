import SwiftUI

struct BookListItems: View {
    var filteredBooks: [Book]
    var viewModel: LibraryViewModel
    var refreshBooks: () -> Void
    var confirmDelete: (IndexSet) -> Void

    @AppStorage("groupBy") private var groupBy: String = "None"

    var groupedBooks: [String: [Book]] {
        switch groupBy {
        case "Genre":
            return Dictionary(grouping: filteredBooks, by: { $0.genre })
        case "Author":
            return Dictionary(grouping: filteredBooks, by: { $0.author })
        default:
            return ["All Books": filteredBooks]
        }
    }

    var body: some View {
        List {
            ForEach(groupedBooks.keys.sorted(), id: \.self) { key in
                Section(header: Text(key).font(.headline)) {
                    ForEach(groupedBooks[key]!, id: \.id) { book in
                        NavigationLink(destination: BookDetailView(viewModel: viewModel, book: book)) {
                            BookListItem(book: book)
                                .contextMenu {
                                    Button(action: {
                                        if let index = filteredBooks.firstIndex(where: { $0.id == book.id }) {
                                            confirmDelete(IndexSet(integer: index))
                                        }
                                    }) {
                                        Text("Delete")
                                        Image(systemName: "trash")
                                    }
                                }
                        }
                    }
                }
            }
        }
        .onAppear {
            refreshBooks()
        }
    }
}

struct BookListItem: View {
    var book: Book

    var body: some View {
        HStack {
            AsyncImage(url: URL(string: book.coverImageUrl)) { image in
                image.resizable()
            } placeholder: {
                Color.gray
            }
            .frame(width: 50, height: 75)
            .cornerRadius(8)
            VStack(alignment: .leading) {
                Text(book.title)
                    .font(.headline)
                Text(book.author)
                    .font(.subheadline)
            }
        }
    }
}

struct BookListItems_Previews: PreviewProvider {
    static var previews: some View {
        BookListItems(filteredBooks: [], viewModel: LibraryViewModel(bookRepository: InMemoryRepository()), refreshBooks: {}, confirmDelete: { _ in })
    }
}
