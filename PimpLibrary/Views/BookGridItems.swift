import SwiftUI

struct BookGridItems: View {
    var filteredBooks: [Book]
    var viewModel: LibraryViewModel
    var refreshBooks: () -> Void
    var confirmDelete: (Book) -> Void
    
    @State private var isEditing = false
    @State private var bookToDelete: Book?
    @State private var showingDeleteAlert = false
    @State private var shakeEffect = false
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(filteredBooks) { book in
                    ZStack(alignment: .topLeading) {
                        if isEditing {
                            Button(action: {
                                confirmDelete(book)
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(Color.gray)
                                    .background(Color.white)
                                    .clipShape(Circle())
                            }
                            .offset(x: -5, y: -5)
                            .zIndex(1)
                        }

                        VStack {
                            if !book.coverImageUrl.isEmpty {
                                if let url = URL(string: book.coverImageUrl) {
                                    AsyncImage(url: url)
                                        .frame(width: 120, height: 160)
                                        .cornerRadius(5)
                                        .aspectRatio(contentMode: .fit)
                                        .rotationEffect(.degrees(shakeEffect ? -2 : 0))
                                        .animation(shakeEffect ? Animation.linear(duration: 0.1).repeatForever(autoreverses: true) : .default, value: shakeEffect)
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
                                .frame(width: 120, height: 160)
                                .background(Color.gray.opacity(0.3))
                                .cornerRadius(5)
                                .rotationEffect(.degrees(shakeEffect ? -2 : 0))
                                .animation(shakeEffect ? Animation.linear(duration: 0.1).repeatForever(autoreverses: true) : .default, value: shakeEffect)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            if !isEditing {
                                if let bookIndex = filteredBooks.firstIndex(where: { $0.id == book.id }) {
                                    viewModel.books[bookIndex] = book
                                }
                            }
                        }
                        .onLongPressGesture {
                            withAnimation {
                                isEditing.toggle()
                                shakeEffect.toggle()
                            }
                        }
                    }
                    .background(
                        NavigationLink(destination: BookDetailView(viewModel: viewModel, book: book)) {
                            EmptyView()
                        }
                        .opacity(0)
                    )
                }
            }
            .padding(.horizontal)
        }
        .refreshable {
            refreshBooks()
        }
    }
}

struct BookGridItems_Previews: PreviewProvider {
    static var previews: some View {
        BookGridItems(
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
