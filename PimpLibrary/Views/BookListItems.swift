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
    }
}
