import SwiftUI

struct BookListItems: View {
    var filteredBooks: [Book]
    var viewModel: LibraryViewModel
    var refreshBooks: () -> Void
    var confirmDelete: (IndexSet) -> Void
    
    var body: some View {
        List {
            ForEach(filteredBooks) { book in
                NavigationLink(destination: BookDetailView(viewModel: viewModel, book: book)) {
                    HStack {

                        if let imageData = book.coverImageData, let uiImage = UIImage(data: imageData) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .frame(width: 60, height: 85)
                                .clipped()
                                .cornerRadius(10)
                        } else {
                            if let url = URL(string: book.coverImageUrl), !book.coverImageUrl.isEmpty {
                                AsyncImage(url: url) { image in
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
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
                        }
                        .padding(.leading, 8)
                    }
                    .padding(.vertical, 5)
                }
            }
            .onDelete(perform: confirmDelete)
        }
        .listStyle(InsetGroupedListStyle())
        .navigationTitle("Books")
        .refreshable {
            refreshBooks()
        }
    }
}

struct BookListItems_Previews: PreviewProvider {
    static var previews: some View {
        BookListItems(
            filteredBooks:  [
                Book(id: UUID(), title: "Sample Book 1", author: "Author 1", year: "2021", description: "Description 1", genre: "Genre 1", coverImageUrl: ""),
                Book(id: UUID(), title: "Sample Book 2", author: "Author 2", year: "2022", description: "Description 2", genre: "Genre 2", coverImageUrl: ""),
                Book(id: UUID(), title: "Sample Book 3", author: "Author 3", year: "2023", description: "Description 3", genre: "Genre 3", coverImageUrl: ""),
            ],
            viewModel: LibraryViewModel(bookRepository: InMemoryRepository()),
            refreshBooks: {},
            confirmDelete: { _ in }
        )
        .previewLayout(.sizeThatFits)
    }
}
