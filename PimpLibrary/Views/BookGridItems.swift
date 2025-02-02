import SwiftUI

struct BookGridItems: View {
    var filteredBooks: [Book]
    var viewModel: LibraryViewModel
    var refreshBooks: () -> Void
    var confirmDelete: (IndexSet) -> Void
    var isLoading: Bool
    
    @AppStorage("groupBy") private var groupBy: String = "None"
    
    // Definizione delle colonne della griglia
    private let columns = [
        GridItem(.flexible(), spacing: 20),
        GridItem(.flexible(), spacing: 20),
        GridItem(.flexible(), spacing: 20)
    ]
    
    // Elementi scheletro per lo stato di caricamento
    private let skeletonItems = Array(0..<6)
    
    // Raggruppamento dei libri in base al criterio selezionato
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
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 10) {
                if isLoading {
                    LazyVGrid(columns: columns, spacing: 20) {
                        ForEach(skeletonItems, id: \.self) { _ in
                            SkeletonBookItem()
                        }
                    }
                    .padding(20)
                } else {
                    ForEach(groupedBooks.keys.sorted(), id: \.self) { key in
                        Section(header: sectionHeader(title: key)) {
                            LazyVGrid(columns: columns, spacing: 20) {
                                ForEach(groupedBooks[key]!, id: \.id) { book in
                                    bookGridItemView(book: book)
                                }
                            }
                        }
                    }
                    .padding(20)
                }
            }
        }
        .refreshable { refreshBooks() }
    }
    
    private func sectionHeader(title: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.title2)
                .bold()
                .padding(.vertical, 5)
                .padding(.horizontal, -16)
                .frame(maxWidth: .infinity, alignment: .leading)
            Divider()
                .background(Color(UIColor.systemGray4))
                .padding(.horizontal, -16)
        }
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
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                        case .success(let image):
                            image.resizable().aspectRatio(contentMode: .fill)
                        case .failure:
                            Color.gray
                        @unknown default:
                            EmptyView()
                        }
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
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 5)
                            Text(book.author)
                                .font(.subheadline)
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 5)
                        }
                    }
                }
                
                Text(book.title)
                    .font(.caption)
                    .lineLimit(1)
                
                if book.totalPages > 0 {
                    ReadingProgressView(currentPage: book.currentPage, totalPages: book.totalPages)
                        .padding(.top, 2)
                }
            }
            .contextMenu {
                Button(role: .destructive) {
                    if let index = filteredBooks.firstIndex(of: book) {
                        confirmDelete(IndexSet(integer: index))
                    }
                } label: {
                    Label("Delete", systemImage: "trash")
                }
            }
        }
    }
}

struct SkeletonBookItem: View {
    @State private var shimmerPosition: CGFloat = -1
    
    var body: some View {
        VStack(spacing: 8) {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(.systemGray5))
                .frame(width: 120, height: 180)
                .overlay(
                    LinearGradient(
                        gradient: Gradient(colors: [.clear, Color.white.opacity(0.4), .clear]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(width: 50)
                    .offset(x: shimmerPosition)
                    .animation(Animation.linear(duration: 1.5).repeatForever(autoreverses: false), value: shimmerPosition)
                )
                .onAppear { shimmerPosition = 1.5 }
            
            RoundedRectangle(cornerRadius: 4)
                .fill(Color(.systemGray5))
                .frame(height: 12)
            
            RoundedRectangle(cornerRadius: 4)
                .fill(Color(.systemGray5))
                .frame(height: 10)
                .frame(width: 80)
        }
        .redacted(reason: .placeholder)
    }
}

struct BookGridItems_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            BookGridItems(
                filteredBooks: [],
                viewModel: LibraryViewModel(bookRepository: InMemoryRepository()),
                refreshBooks: {},
                confirmDelete: { _ in },
                isLoading: true
            )
            .previewDisplayName("Loading State")
            
            BookGridItems(
                filteredBooks: [
                    Book(id: UUID(), isbn: "1234567890", title: "Sample Book 1", author: "Author 1", year: "2021", description: "Description 1", genre: "Genre 1", coverImageUrl: "", coverImageData: nil, currentPage: 150, totalPages: 300),
                    Book(id: UUID(), isbn: "0987654321", title: "Sample Book 2", author: "Author 2", year: "2022", description: "Description 2", genre: "Genre 2", coverImageUrl: "", coverImageData: nil, currentPage: 120, totalPages: 450),
                    Book(id: UUID(), isbn: "1122334455", title: "Sample Book 3", author: "Author 3", year: "2023", description: "Description 3", genre: "Genre 3", coverImageUrl: "", coverImageData: nil, currentPage: 0, totalPages: 280)
                ],
                viewModel: LibraryViewModel(bookRepository: InMemoryRepository()),
                refreshBooks: {},
                confirmDelete: { _ in },
                isLoading: false
            )
            .previewDisplayName("Loaded State")
        }
        .previewLayout(.sizeThatFits)
    }
}
