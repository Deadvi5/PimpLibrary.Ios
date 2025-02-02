import SwiftUI

struct BookListItems: View {
    var filteredBooks: [Book]
    var viewModel: LibraryViewModel
    var refreshBooks: () -> Void
    var confirmDelete: (IndexSet) -> Void
    
    @AppStorage("groupBy") private var groupBy: String = "None"
    
    // Raggruppa i libri in base al criterio selezionato
    private var groupedBooks: [String: [Book]] {
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
                        navigationLinkForBook(book: book)
                    }
                    .onDelete { indexSet in
                        handleDelete(at: indexSet, for: key)
                    }
                }
            }
        }
        .onAppear { refreshBooks() }
        .refreshable { refreshBooks() }
    }
    
    private func navigationLinkForBook(book: Book) -> some View {
        NavigationLink(destination: BookDetailView(viewModel: viewModel, book: book)) {
            BookListItem(book: book)
                .contextMenu {
                    Button(action: {
                        if let index = filteredBooks.firstIndex(where: { $0.id == book.id }) {
                            confirmDelete(IndexSet(integer: index))
                        }
                    }) {
                        Label("Delete", systemImage: "trash")
                    }
                }
        }
    }
    
    private func handleDelete(at indexSet: IndexSet, for key: String) {
        guard let index = indexSet.first else { return }
        let book = groupedBooks[key]![index]
        if let globalIndex = filteredBooks.firstIndex(where: { $0.id == book.id }) {
            confirmDelete(IndexSet(integer: globalIndex))
        }
    }
}

struct BookListItem: View {
    var book: Book
    
    var body: some View {
        HStack {
            bookImageView
            bookInfoView
        }
        .padding(.vertical, 5)
    }
    
    private var bookImageView: some View {
        Group {
            if let imageData = book.coverImageData, let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .frame(width: 60, height: 85)
                    .clipped()
                    .cornerRadius(10)
            } else if let url = URL(string: book.coverImageUrl), !book.coverImageUrl.isEmpty {
                AsyncImage(url: url) { image in
                    image.resizable().aspectRatio(contentMode: .fill)
                } placeholder: {
                    Color.gray
                }
                .frame(width: 60, height: 85)
                .clipped()
                .cornerRadius(10)
            } else {
                ZStack {
                    Color.gray
                        .frame(width: 60, height: 85)
                        .cornerRadius(10)
                }
            }
        }
    }
    
    private var bookInfoView: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(book.title)
                .font(.headline)
            Text(book.author)
                .font(.subheadline)
                .foregroundColor(.secondary)
            Text(book.genre)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(book.year)
                .font(.caption)
                .foregroundColor(.secondary)
            if book.totalPages > 0 {
                ReadingProgressView(currentPage: book.currentPage, totalPages: book.totalPages)
                    .padding(.top, 4)
            }
        }
        .padding(.leading, 8)
    }
}

struct BookListItems_Previews: PreviewProvider {
    static var previews: some View {
        BookListItems(
            filteredBooks: [
                Book(id: UUID(), isbn: "1111111111", title: "Sample Book 1", author: "Author 1", year: "2021", description: "Description 1", genre: "Genre 1", coverImageUrl: "", coverImageData: nil, currentPage: 150, totalPages: 300),
                Book(id: UUID(), isbn: "2222222222", title: "Sample Book 2", author: "Author 2", year: "2022", description: "Description 2", genre: "Genre 2", coverImageUrl: "", coverImageData: nil, currentPage: 120, totalPages: 450),
                Book(id: UUID(), isbn: "3333333333", title: "Sample Book 3", author: "Author 3", year: "2023", description: "Description 3", genre: "Genre 3", coverImageUrl: "", coverImageData: nil, currentPage: 0, totalPages: 280)
            ],
            viewModel: LibraryViewModel(bookRepository: InMemoryRepository()),
            refreshBooks: {},
            confirmDelete: { _ in }
        )
        .previewLayout(.sizeThatFits)
    }
}
