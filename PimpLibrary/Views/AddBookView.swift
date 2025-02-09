import SwiftUI

struct AddBookView: View {
    @ObservedObject var viewModel: LibraryViewModel
    @State private var title: String = ""
    @State private var author: String = ""
    @State private var year: String = ""
    @State private var genre: String = ""
    @State private var description: String = ""
    @State private var coverImageUrl: String = ""
    @State private var coverImageData: Data?
    @State private var totalPages: Int = 0

    @State private var showingSearchOptions = false
    @State private var showingBarcodeScanner = false
    @State private var showingISBNSearch = false
    @State private var showingTitleSearch = false
    @State private var showCamera = false
    @State private var capturedImage: UIImage?

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Back Button
                HStack {
                    Button(action: { dismiss() }) {
                        Label("Back", systemImage: "chevron.left")
                            .foregroundColor(.blue)
                    }
                    Spacer()
                }
                .padding([.top, .horizontal])

                Text("Add Book")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.horizontal)

                // Cover Image
                VStack {
                    if let imageData = coverImageData, let uiImage = UIImage(data: imageData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 220)
                            .cornerRadius(12)
                            .shadow(radius: 5)
                            .onTapGesture { showCamera = true }
                    } else if let url = URL(string: coverImageUrl), !coverImageUrl.isEmpty {
                        AsyncImage(url: url) { image in
                            image.resizable().aspectRatio(contentMode: .fit)
                        } placeholder: {
                            Color.gray
                        }
                        .frame(height: 220)
                        .cornerRadius(12)
                        .shadow(radius: 5)
                        .onTapGesture { showCamera = true }
                    } else {
                        Color.gray
                            .frame(height: 220)
                            .cornerRadius(12)
                            .shadow(radius: 5)
                            .overlay(
                                VStack {
                                    Image(systemName: "camera")
                                        .font(.largeTitle)
                                        .foregroundColor(.white)
                                    Text("Tap to add cover")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                }
                            )
                            .onTapGesture { showCamera = true }
                    }
                }
                .padding(.horizontal)
                .sheet(isPresented: $showCamera) { CameraCaptureView(image: $capturedImage) }
                .onChange(of: capturedImage) { newImage, _ in
                    if let newImage = newImage,
                       let cropped = ImageUtilities.cropBookCover(from: newImage) {
                        coverImageData = cropped.jpegData(compressionQuality: 0.8)
                    }
                }

                // Book Details Form
                Group {
                    DetailFieldView(label: "Title", text: $title)
                    DetailFieldView(label: "Author", text: $author)
                    DetailFieldView(label: "Year", text: $year)
                    DetailFieldView(label: "Genre", text: $genre)
                    DetailFieldView(label: "Description", text: $description, isMultiline: true)
                }
                .padding(.horizontal)

                // Buttons
                HStack(spacing: 16) {
                    Button(action: { showingSearchOptions = true }) {
                        Text("Search Book")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .cornerRadius(10)
                    }

                    Button(action: {
                        viewModel.addBook(
                            title: title,
                            author: author,
                            year: year,
                            genre: genre,
                            description: description,
                            coverImageUrl: coverImageUrl,
                            coverImageData: coverImageData,
                            currentPage: 0,
                            totalPages: totalPages
                        )
                        dismiss()
                    }) {
                        Text("Add")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                }
                .padding(.horizontal)

                Spacer()
            }
            .padding(.vertical)
            .background(Color(UIColor.systemGroupedBackground))
            .navigationBarHidden(true)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    showingBarcodeScanner = true
                }
            }
            .sheet(isPresented: $showingBarcodeScanner) {
                BarcodeScannerView(isbn: .constant(""), onISBNScanned: { isbn in
                    searchBook(by: .isbn, query: isbn)
                })
            }
            .actionSheet(isPresented: $showingSearchOptions) {
                ActionSheet(title: Text("Search Book"), message: Text("Choose a method to search for the book."), buttons: [
                    .default(Text("Search by ISBN")) { showingISBNSearch = true },
                    .default(Text("Search by Title")) { showingTitleSearch = true },
                    .cancel()
                ])
            }
            .sheet(isPresented: $showingISBNSearch) {
                BookSearchView(searchType: .isbn) { result in
                    handleSearchResult(result)
                }
            }
            .sheet(isPresented: $showingTitleSearch) {
                BookSearchView(searchType: .title) { result in
                    handleSearchResult(result)
                }
            }
        }
    }

    func searchBook(by type: BookSearchType, query: String) {
        let selectedAPI = UserDefaults.standard.string(forKey: "selectedAPI") ?? "Google Books"
        let isbnService: IsbnService = (selectedAPI == "Google Books") ? GoogleBookIsbnService() : OpenLibraryIsbnService()

        switch type {
        case .isbn:
            isbnService.fetchBookDetails(isbn: query, completion: handleSearchResult)
        case .title:
            isbnService.fetchBookDetails(title: query, completion: handleSearchResult)
        }
    }

    func handleSearchResult(_ result: Result<Book, Error>) {
        switch result {
        case .success(let bookDetails):
            DispatchQueue.main.async {
                title = bookDetails.title
                author = bookDetails.author
                year = bookDetails.year
                genre = bookDetails.genre
                description = bookDetails.description
                coverImageUrl = bookDetails.coverImageUrl
                coverImageData = bookDetails.coverImageData
                totalPages = bookDetails.totalPages
            }
        case .failure(let error):
            print("Error fetching book: \(error.localizedDescription)")
        }
    }
}

struct AddBookView_Previews: PreviewProvider {
    static var previews: some View {
        AddBookView(viewModel: LibraryViewModel(bookRepository: InMemoryRepository()))
    }
}

enum BookSearchType {
    case isbn
    case title
}
