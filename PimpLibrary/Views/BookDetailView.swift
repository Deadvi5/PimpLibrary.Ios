import SwiftUI

struct BookDetailView: View {
    @ObservedObject var viewModel: LibraryViewModel
    @State var book: Book
    @State private var showCamera = false
    @State private var capturedImage: UIImage?
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Top Bar with Back Button
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
                Text("Edit Book")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.horizontal)
                
                // Book Cover Image with Tap Gesture to Open Camera
                VStack {
                    if let imageData = book.coverImageData, let uiImage = UIImage(data: imageData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 200)
                            .cornerRadius(10)
                            .shadow(radius: 5)
                            .onTapGesture {
                                showCamera = true
                            }
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
                        book.coverImageData = croppedImage.jpegData(compressionQuality: 0.8)
                    }
                }

                // Book Details Form
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
    }
}

struct BookDetailView_Previews: PreviewProvider {
    static var previews: some View {
        BookDetailView(viewModel: LibraryViewModel(bookRepository: InMemoryRepository()), book: Book(id: UUID(), title: "Sample Book", author: "Author", year: "2020", description: "An adventure", genre: "Thriller", coverImageUrl: "https://marketplace.canva.com/EAFaQMYuZbo/1/0/1003w/canva-brown-rusty-mystery-novel-book-cover-hG1QhA7BiBU.jpg"))
    }
}
