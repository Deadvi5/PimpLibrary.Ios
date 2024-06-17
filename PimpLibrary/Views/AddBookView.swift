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
    
    @State private var showingISBNInput = false
    @State private var showingBarcodeScanner = false
    @State private var showCamera = false
    @State private var capturedImage: UIImage?
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        HStack {
                            Image(systemName: "chevron.left")
                                .font(.headline)
                            Text("Back")
                                .font(.headline)
                        }
                        .foregroundColor(.blue)
                    }
                    Spacer()
                }
                .padding([.top, .horizontal])
                
                // Title
                Text("Add Book")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.horizontal)
                
                // Book Cover Image with Tap Gesture to Open Camera
                VStack {
                    if let imageData = coverImageData, let uiImage = UIImage(data: imageData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 200)
                            .cornerRadius(10)
                            .shadow(radius: 5)
                            .onTapGesture {
                                showCamera = true
                            }
                    } else if let url = URL(string: coverImageUrl), !coverImageUrl.isEmpty {
                        AsyncImage(url: url) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                        } placeholder: {
                            Color.gray
                        }
                        .frame(height: 200)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                        .onTapGesture {
                            showCamera = true
                        }
                    } else {
                        Color.gray
                            .frame(height: 200)
                            .cornerRadius(10)
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
                            .onTapGesture {
                                showCamera = true
                            }
                    }
                }
                .padding(.horizontal)
                .sheet(isPresented: $showCamera) {
                    CameraCaptureView(image: $capturedImage)
                }
                .onChange(of: capturedImage) { newImage,_ in
                    if let newImage = newImage, let croppedImage = ImageUtilities.cropBookCover(from: newImage) {
                        coverImageData = croppedImage.jpegData(compressionQuality: 0.8)
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
                
                HStack(spacing: 16) {
                    Button(action: {
                        showingBarcodeScanner = true
                    }) {
                        Text("Scan ISBN")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .cornerRadius(10)
                    }
                    
                    Button(action: {
                        viewModel.addBook(title: title, author: author, year: year, genre: genre, description: description, coverImageUrl: coverImageUrl, coverImageData: coverImageData)
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
                    searchBook(isbn: isbn)
                })
            }
            .sheet(isPresented: $showingISBNInput) {
                IsbnInputView(onBookFound: { foundTitle, foundAuthor, foundYear, foundGenre, foundDescription, foundCoverImage in
                    title = foundTitle
                    author = foundAuthor
                    year = foundYear
                    genre = foundGenre
                    description = foundDescription
                    coverImageUrl = foundCoverImage
                    viewModel.addBook(title: title, author: author, year: year, genre: genre, description: description, coverImageUrl: coverImageUrl, coverImageData: coverImageData)
                    dismiss()
                }, isbnService: GoogleBookIsbnService())
            }
        }
    }
    
    func searchBook(isbn: String) {
        let isbnService = GoogleBookIsbnService()
        isbnService.fetchBookDetails(isbn: isbn) { result in
            switch result {
            case .success(let bookDetails):
                title = bookDetails.title
                author = bookDetails.author
                year = bookDetails.year
                genre = bookDetails.genre
                description = bookDetails.description
                coverImageUrl = bookDetails.coverImageUrl
                coverImageData = bookDetails.coverImageData
                viewModel.addBook(title: title, author: author, year: year, genre: genre, description: description, coverImageUrl: coverImageUrl, coverImageData: coverImageData)
                dismiss()
            case .failure:
                showingISBNInput = true
            }
        }
    }
}

struct AddBookView_Previews: PreviewProvider {
    static var previews: some View {
        AddBookView(viewModel: LibraryViewModel(bookRepository: InMemoryRepository()))
    }
}
