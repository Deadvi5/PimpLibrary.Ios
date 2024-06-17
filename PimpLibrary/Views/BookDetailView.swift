import SwiftUI

struct BookDetailView: View {
    @ObservedObject var viewModel: LibraryViewModel
    @State var book: Book
    @State private var showCamera = false
    @State private var showImagePicker = false
    @State private var capturedImage: UIImage?
    @State private var selectedImage: UIImage?
    @State private var showingActionSheet = false
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
                
                Text("Edit Book")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.horizontal)
                
                VStack {
                    if let imageData = book.coverImageData, let uiImage = UIImage(data: imageData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 200)
                            .cornerRadius(10)
                            .shadow(radius: 5)
                    } else if let url = URL(string: book.coverImageUrl), !book.coverImageUrl.isEmpty {
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
                    }
                }
                .padding(.horizontal)
                .onTapGesture {
                    showImageOptions()
                }
                .sheet(isPresented: $showCamera) {
                    CameraCaptureView(image: $capturedImage)
                }
                .sheet(isPresented: $showImagePicker) {
                    ImagePicker(image: $selectedImage)
                }
                .onChange(of: capturedImage) { newImage in
                    if let newImage = newImage {
                        updateBookCoverImage(newImage)
                    }
                }
                .onChange(of: selectedImage) { newImage in
                    if let newImage = newImage {
                        updateBookCoverImage(newImage)
                    }
                }

                Group {
                    DetailFieldView(label: "Title", text: $book.title)
                    DetailFieldView(label: "Author", text: $book.author)
                    DetailFieldView(label: "Year", text: $book.year)
                    DetailFieldView(label: "Genre", text: $book.genre)
                    DetailFieldView(label: "Description", text: $book.description, isMultiline: true)
                }
                .padding(.horizontal)
                
                Spacer()
                
                Button(action: {
                    viewModel.editBook(
                        book: book,
                        title: book.title,
                        author: book.author,
                        year: book.year,
                        genre: book.genre,
                        description: book.description,
                        bookCoverImageData: book.coverImageData
                    )
                    dismiss()
                }) {
                    Text("Save")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                        .padding(.horizontal)
                        .shadow(radius: 5)
                }
            }
            .padding(.vertical)
        }
        .background(Color(UIColor.systemGroupedBackground))
        .navigationBarHidden(true)
        .actionSheet(isPresented: $showingActionSheet) {
            ActionSheet(
                title: Text("Select Cover Image"),
                message: nil,
                buttons: [
                    .default(Text("Take Photo")) {
                        showCamera = true
                    },
                    .default(Text("Choose from Gallery")) {
                        showImagePicker = true
                    },
                    .cancel()
                ]
            )
        }
    }
    
    private func showImageOptions() {
        showingActionSheet = true
    }

    private func updateBookCoverImage(_ newImage: UIImage) {
            book.coverImageData = newImage.jpegData(compressionQuality: 0.8)
            book = book
    }
}

struct BookDetailView_Previews: PreviewProvider {
    static var previews: some View {
        BookDetailView(viewModel: LibraryViewModel(bookRepository: InMemoryRepository()), book: Book(id: UUID(), title: "Sample Book", author: "Author", year: "2020", description: "An adventure", genre: "Thriller", coverImageUrl: "https://marketplace.canva.com/EAFaQMYuZbo/1/0/1003w/canva-brown-rusty-mystery-novel-book-cover-hG1QhA7BiBU.jpg"))
    }
}
