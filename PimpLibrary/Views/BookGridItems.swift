import SwiftUI

struct BookGridItems: View {
    var filteredBooks: [Book]
    var viewModel: LibraryViewModel
    var refreshBooks: () -> Void
    var confirmDelete: (IndexSet) -> Void
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 20) {
                ForEach(filteredBooks) { book in
                    NavigationLink(destination: BookDetailView(viewModel: viewModel, book: book)) {
                        VStack {
                            if !book.coverImageUrl.isEmpty {
                                if let url = URL(string: book.coverImageUrl) {
                                    AsyncImage(url: url)
                                        .frame(width: 100, height: 100)
                                        .cornerRadius(5)
                                        .aspectRatio(contentMode: .fit)
                                }
                            } else {
                                VStack {
                                    Text(book.title)
                                        .font(.headline)
                                        .multilineTextAlignment(.center)
                                    Text(book.author)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                        .multilineTextAlignment(.center)
                                }
                                .frame(width: 100, height: 100)
                                .background(Color.gray.opacity(0.3))
                                .cornerRadius(5)
                            }
                        }
                    }
                }
            }
            .padding()
        }
        .refreshable {
            refreshBooks()
        }
    }
}
