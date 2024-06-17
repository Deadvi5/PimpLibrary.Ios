import SwiftUI

struct BookGridItems: View {
    var filteredBooks: [Book]
    var viewModel: LibraryViewModel
    var refreshBooks: () -> Void
    var confirmDelete: (IndexSet) -> Void
    
    @AppStorage("groupBy") private var groupBy: String = "None"
    @State private var isEditing = false
    @State private var bookToDelete: Book?
    @State private var showingDeleteAlert = false
    @State private var shakeEffect = false

    let columns = [
        GridItem(.flexible(), spacing: 20),
        GridItem(.flexible(), spacing: 20),
        GridItem(.flexible(), spacing: 20)
    ]

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
            LazyVStack(alignment: .leading, spacing: 10) {
                ForEach(groupedBooks.keys.sorted(), id: \.self) { key in
                    Section(header: sectionHeader(title: key)) {
                        LazyVGrid(columns: columns, spacing: 20) {
                            ForEach(groupedBooks[key]!, id: \.id) { book in
                                bookGridItemView(book: book)
                            }
                        }
                    }
                }
            }
            .padding(.all, 20)
        }
        .refreshable {
            refreshBooks()
        }
    }

    private func sectionHeader(title: String) -> some View {
        Text(title)
            .font(.title2)
            .bold()
            .padding(.vertical, 5)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(UIColor.systemGray5))
            .cornerRadius(8)
            .padding(.horizontal, -16) // Adjust for the outer padding
    }

    private func bookGridItemView(book: Book) -> some View {
        NavigationLink(destination: BookDetailView(viewModel: viewModel, book: book)) {
            VStack {
                if let imageData = book.coverImageData, let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .frame(width: 120, height: 180)
                        .clipped()
                        .cornerRadius(10)
                } else if let url = URL(string: book.coverImageUrl), !book.coverImageUrl.isEmpty {
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Color.gray
                    }
                    .frame(width: 120, height: 180)
                    .clipped()
                    .cornerRadius(10)
                } else {
                    ZStack {
                        Color.gray
                            .frame(width: 120, height: 180)
                            .cornerRadius(10)
                        VStack {
                            Text(book.title)
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding([.leading, .trailing], 5)
                                .multilineTextAlignment(.center)
                            Text(book.author)
                                .font(.subheadline)
                                .foregroundColor(.white)
                                .padding([.leading, .trailing], 5)
                                .multilineTextAlignment(.center)
                        }
                    }
                }

                Text(book.title)
                    .font(.caption)
                    .lineLimit(1)
            }
            .contextMenu {
                Button(role: .destructive, action: {
                    if let index = filteredBooks.firstIndex(of: book) {
                        confirmDelete(IndexSet(integer: index))
                    }
                }) {
                    Label("Delete", systemImage: "trash")
                }
            }
        }
    }
}

struct BookGridItems_Previews: PreviewProvider {
    static var previews: some View {
        BookGridItems(
            filteredBooks: [
                Book(id: UUID(), title: "Sample Book 1", author: "Author 1", year: "2021", description: "Description 1", genre: "Genre 1", coverImageUrl: ""),
                Book(id: UUID(), title: "Sample Book 2", author: "Author 2", year: "2022", description: "Description 2", genre: "Genre 2", coverImageUrl: ""),
                Book(id: UUID(), title: "Sample Book 3", author: "Author 3", year: "2023", description: "Description 3", genre: "Genre 3", coverImageUrl: ""),
                Book(id: UUID(), title: "Sample Book 4", author: "Author 4", year: "2021", description: "Description 1", genre: "Genre 1", coverImageUrl: ""),
                Book(id: UUID(), title: "Sample Book 5", author: "Author 5", year: "2022", description: "Description 2", genre: "Genre 2", coverImageUrl: ""),
                Book(id: UUID(), title: "Sample Book 6", author: "Author 6", year: "2023", description: "Description 3", genre: "Genre 3", coverImageUrl: ""),
            ],
            viewModel: LibraryViewModel(bookRepository: InMemoryRepository()),
            refreshBooks: {},
            confirmDelete: { _ in }
        )
        .previewLayout(.sizeThatFits)
    }
}
