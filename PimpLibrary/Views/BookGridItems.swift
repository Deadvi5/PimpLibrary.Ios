import SwiftUI

struct BookGridItems: View {
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
        ScrollView {
            LazyVStack {
                ForEach(groupedBooks.keys.sorted(), id: \.self) { key in
                    Section(header: Text(key).font(.headline).padding(.top)) {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))]) {
                            ForEach(groupedBooks[key]!, id: \.id) { book in
                                bookGridItemView(book: book)
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

    private func bookGridItemView(book: Book) -> some View {
        NavigationLink(destination: BookDetailView(viewModel: viewModel, book: book)) {
            BookGridItem(book: book)
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

struct BookGridItem: View {
    var book: Book

    var body: some View {
        VStack {
            AsyncImage(url: URL(string: book.coverImageUrl)) { image in
                image.resizable()
            } placeholder: {
                Color.gray
            }
            .frame(width: 100, height: 150)
            .cornerRadius(8)
            Text(book.title)
                .font(.caption)
                .lineLimit(1)
        }
    }
}

struct BookGridItems_Previews: PreviewProvider {
    static var previews: some View {
        BookGridItems(filteredBooks: [], viewModel: LibraryViewModel(bookRepository: InMemoryRepository()), refreshBooks: {}, confirmDelete: { _ in })
    }
}
