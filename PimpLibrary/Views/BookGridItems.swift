import SwiftUI

struct BookGridItems: View {
    var filteredBooks: [Book]
    var viewModel: LibraryViewModel
    var refreshBooks: () -> Void
    var confirmDelete: (IndexSet) -> Void
    
    @State private var isEditing = false
    @State private var bookToDelete: Book?
    @State private var showingDeleteAlert = false
    @State private var shakeEffect = false
    
    let columns = [
        GridItem(.flexible(), spacing: 20),
        GridItem(.flexible(), spacing: 20),
        GridItem(.flexible(), spacing: 20)
    ]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 5) {
                ForEach(filteredBooks) { book in
                    NavigationLink(destination: BookDetailView(viewModel: viewModel, book: book)) {
                        VStack {
                            if let url = URL(string: book.coverImageUrl), !book.coverImageUrl.isEmpty {
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
                        }
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
            .padding(.all, 20)
        }
        .refreshable {
            refreshBooks()
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
            ],
            viewModel: LibraryViewModel(bookRepository: InMemoryRepository()),
            refreshBooks: {},
            confirmDelete: { _ in }
        )
        .previewLayout(.sizeThatFits)
    }
}
