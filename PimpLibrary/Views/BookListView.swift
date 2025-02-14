import SwiftUI

struct BookListView: View {
    @ObservedObject var viewModel: LibraryViewModel
    @State private var showingAlert = false
    @State private var bookToDelete: Book?
    @State private var searchText = ""
    @State private var isSearchBarVisible = false
    @State private var sortCriteria = "Title"
    @State private var isAscending = true
    @State private var isLoading = false
    @State private var textOffset: CGFloat = -UIScreen.main.bounds.width
    @State private var textOpacity: Double = 0.0
    @AppStorage("useGridView") private var useGridView: Bool = false

    init(viewModel: LibraryViewModel = LibraryViewModel(bookRepository: RealmBookRepository())) {
        self.viewModel = viewModel
    }

    private var sortedBooks: [Book] {
        sortBooks(books: viewModel.books, by: sortCriteria, ascending: isAscending)
    }

    private var filteredBooks: [Book] {
        if searchText.isEmpty { return sortedBooks }
        return sortedBooks.filter { $0.title.lowercased().contains(searchText.lowercased()) }
    }

    var body: some View {
        VStack(spacing: 0) {
            headerView

            if isSearchBarVisible {
                SearchBarView(text: $searchText)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .frame(maxWidth: .infinity)
            }

            if isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .scaleEffect(1.5)
                    .padding()
            }

            Group {
                if useGridView {
                    BookGridItems(
                        filteredBooks: filteredBooks,
                        viewModel: viewModel,
                        refreshBooks: refreshBooks,
                        confirmDelete: confirmDelete(at:),
                        isLoading: isLoading
                    )
                } else {
                    BookListItems(
                        filteredBooks: filteredBooks,
                        viewModel: viewModel,
                        refreshBooks: refreshBooks,
                        confirmDelete: confirmDelete(at:)
                    )
                }
            }
            .background(Color(.systemGroupedBackground))
        }
        .edgesIgnoringSafeArea(.top)
        .navigationBarHidden(true)
        .alert(isPresented: $showingAlert) {
            Alert(
                title: Text("Delete Book"),
                message: Text("Are you sure you want to delete \(bookToDelete?.title ?? "")?"),
                primaryButton: .destructive(Text("Delete")) {
                    if let book = bookToDelete {
                        viewModel.removeBook(book: book)
                    }
                },
                secondaryButton: .cancel()
            )
        }
        .onAppear {
            animateTextEntrance()
        }
    }

    private var headerView: some View {
        VStack(spacing: 0) {
            LinearGradient(gradient: Gradient(colors: [Color.blue, Color.purple]), startPoint: .topLeading, endPoint: .bottomTrailing)
                .frame(height: 120)
                .overlay(
                    HStack(spacing: 16) {
                        Text("PimpLibrary")
                            .font(.system(size: 22, weight: .bold))
                            .modifier(AnimatedEntrance(offset: $textOffset, opacity: $textOpacity))
                            .foregroundColor(.white)
                        Spacer()
                        NavigationLink(destination: SortingOptionsView(sortCriteria: $sortCriteria, isAscending: $isAscending)) {
                            headerButtonContent(systemName: "arrow.up.arrow.down")
                        }
                        headerButton(systemName: "magnifyingglass") { withAnimation { isSearchBarVisible.toggle() } }
                        NavigationLink(destination: AddBookView(viewModel: viewModel)) {
                            headerButtonContent(systemName: "plus")
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, UIApplication.shared.connectedScenes
                        .compactMap { ($0 as? UIWindowScene)?.keyWindow }
                        .first?.safeAreaInsets.top ?? 20)
                )
        }
    }

    private func headerButton(systemName: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            headerButtonContent(systemName: systemName)
        }
    }

    private func headerButtonContent(systemName: String) -> some View {
        Image(systemName: systemName)
            .imageScale(.medium)
            .padding(8)
            .background(Color.white.opacity(0.2))
            .clipShape(Circle())
            .foregroundColor(.white)
    }

    private func sortBooks(books: [Book], by criteria: String, ascending: Bool) -> [Book] {
        switch criteria {
        case "Title":
            return books.sorted {
                ascending ? $0.title.lowercased() < $1.title.lowercased()
                          : $0.title.lowercased() > $1.title.lowercased()
            }
        case "Author":
            return books.sorted {
                ascending ? $0.author.lowercased() < $1.author.lowercased()
                          : $0.author.lowercased() > $1.author.lowercased()
            }
        case "Year":
            return books.sorted {
                ascending ? $0.year < $1.year : $0.year > $1.year
            }
        default:
            return books
        }
    }

    private func refreshBooks() {
        isLoading = true
        DispatchQueue.global().async {
            let books = viewModel.bookRepository.fetchBooks()
            DispatchQueue.main.async {
                viewModel.books = books
                isLoading = false
            }
        }
    }

    private func confirmDelete(at offsets: IndexSet) {
        for index in offsets {
            let book = filteredBooks[index]
            if let bookIndex = viewModel.books.firstIndex(where: { $0.id == book.id }) {
                bookToDelete = viewModel.books[bookIndex]
                showingAlert = true
            }
        }
    }

    private func animateTextEntrance() {
        withAnimation(.easeInOut(duration: 1.0)) {
            textOffset = 0
            textOpacity = 1.0
        }
    }
}

struct AnimatedEntrance: ViewModifier {
    @Binding var offset: CGFloat
    @Binding var opacity: Double

    func body(content: Content) -> some View {
        content
            .offset(x: offset)
            .opacity(opacity)
    }
}

struct BookListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            BookListView(viewModel: LibraryViewModel(bookRepository: InMemoryRepository()))
        }
    }
}
