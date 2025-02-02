import SwiftUI
import AVFoundation
import Vision

struct BookDetailView: View {
    @ObservedObject var viewModel: LibraryViewModel
    @State var book: Book

    // Image picker states
    @State private var showCamera = false
    @State private var showImagePicker = false
    @State private var capturedImage: UIImage?
    @State private var selectedImage: UIImage?
    @State private var showingActionSheet = false

    // Editing progress states
    @State private var editingProgress = false
    @State private var newCurrentPage: Int = 0
    @State private var newTotalPages: Int = 0
    @State private var showPageValidationError = false

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                navBar
                Text("Edit Book")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.horizontal)
                coverImageSection
                readingProgressSection
                if editingProgress { updateProgressSection }
                detailFieldsSection
                Spacer()
                saveButton
            }
            .padding(.vertical)
        }
        .background(Color(UIColor.systemGroupedBackground))
        .navigationBarHidden(true)
        .actionSheet(isPresented: $showingActionSheet) {
            ActionSheet(
                title: Text("Select Cover Image"),
                buttons: [
                    .default(Text("Take Photo")) { showCamera = true },
                    .default(Text("Choose from Gallery")) { showImagePicker = true },
                    .cancel()
                ]
            )
        }
        .alert("Invalid Page Number", isPresented: $showPageValidationError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Current page cannot exceed total pages")
        }
        .onAppear {
            newCurrentPage = book.currentPage
            newTotalPages = book.totalPages
        }
        .sheet(isPresented: $showCamera) { CameraCaptureView(image: $capturedImage) }
        .sheet(isPresented: $showImagePicker) { ImagePicker(image: $selectedImage) }
        .onChange(of: capturedImage) { newImage in
            if let newImage = newImage,
               let cropped = ImageUtilities.cropBookCover(from: newImage) {
                updateBookCoverImage(cropped)
            }
        }
        .onChange(of: selectedImage) { newImage in
            if let newImage = newImage,
               let cropped = ImageUtilities.cropBookCover(from: newImage) {
                updateBookCoverImage(cropped)
            }
        }
    }
    
    // MARK: - Subviews
    
    private var navBar: some View {
        HStack {
            Button(action: { dismiss() }) {
                Label("Back", systemImage: "chevron.left")
                    .foregroundColor(.blue)
            }
            Spacer()
        }
        .padding([.top, .horizontal])
    }
    
    private var coverImageSection: some View {
        VStack {
            coverImageView
        }
        .padding(.horizontal)
        .onTapGesture { showingActionSheet = true }
    }
    
    private var coverImageView: some View {
        Group {
            if let imageData = book.coverImageData, let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 220)
                    .cornerRadius(12)
                    .shadow(radius: 5)
            } else if let url = URL(string: book.coverImageUrl), !book.coverImageUrl.isEmpty {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                    case .success(let image):
                        image.resizable().aspectRatio(contentMode: .fit)
                    case .failure:
                        Color.gray
                    @unknown default:
                        EmptyView()
                    }
                }
                .frame(height: 220)
                .cornerRadius(12)
                .shadow(radius: 5)
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
            }
        }
    }
    
    private var readingProgressSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Reading Progress")
                .font(.title2)
                .bold()
            ProgressView(value: progressValue, total: 1.0)
                .progressViewStyle(ReadingProgressStyle())
                .padding(.vertical, 8)
            HStack {
                Text("\(book.currentPage)/\(book.totalPages) pages")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Spacer()
                Button(action: { editingProgress = true }) {
                    Image(systemName: "square.and.pencil")
                        .foregroundColor(.blue)
                }
            }
            if book.totalPages > 0 {
                HStack {
                    Text("\(Int(progressValue * 100))% Complete")
                        .font(.caption)
                        .foregroundColor(.blue)
                    Spacer()
                    Text(estimatedCompletionDate)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .padding(.horizontal)
    }
    
    private var updateProgressSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Update Progress")
                .font(.headline)
            HStack {
                VStack(alignment: .leading) {
                    Text("Current Page")
                    TextField("Current Page", value: $newCurrentPage, formatter: NumberFormatter())
                        .keyboardType(.numberPad)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                VStack(alignment: .leading) {
                    Text("Total Pages")
                    TextField("Total Pages", value: $newTotalPages, formatter: NumberFormatter())
                        .keyboardType(.numberPad)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                Spacer()
                Button("Cancel") {
                    editingProgress = false
                    newCurrentPage = book.currentPage
                    newTotalPages = book.totalPages
                }
                Button("Save") {
                    guard newCurrentPage <= newTotalPages else {
                        showPageValidationError = true
                        return
                    }
                    // Immediately update progress via the view model
                    viewModel.updateBookProgress(book: book, currentPage: newCurrentPage, totalPages: newTotalPages)
                    // Also update local state
                    book.currentPage = newCurrentPage
                    book.totalPages = newTotalPages
                    editingProgress = false
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .padding(.horizontal)
    }
    
    private var detailFieldsSection: some View {
        Group {
            DetailFieldView(label: "Title", text: $book.title)
            DetailFieldView(label: "Author", text: $book.author)
            DetailFieldView(label: "Year", text: $book.year)
            DetailFieldView(label: "Genre", text: $book.genre)
            DetailFieldView(label: "Description", text: $book.description, isMultiline: true)
        }
        .padding(.horizontal)
    }
    
    private var saveButton: some View {
        Button(action: {
            viewModel.editBook(
                book: book,
                title: book.title,
                author: book.author,
                year: book.year,
                genre: book.genre,
                description: book.description,
                coverImageData: book.coverImageData,
                currentPage: book.currentPage,
                totalPages: book.totalPages
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
    
    // MARK: - Helpers
    
    private var progressValue: Double {
        guard book.totalPages > 0 else { return 0 }
        return Double(book.currentPage) / Double(book.totalPages)
    }
    
    private var estimatedCompletionDate: String {
        guard book.currentPage > 0 && book.totalPages > 0 else { return "Not started" }
        let pagesLeft = book.totalPages - book.currentPage
        let pagesPerDay = UserDefaults.standard.integer(forKey: "pagesPerDay")
        let effectivePagesPerDay = pagesPerDay > 0 ? pagesPerDay : 20
        let daysLeft = pagesLeft / effectivePagesPerDay
        let date = Calendar.current.date(byAdding: .day, value: daysLeft, to: Date()) ?? Date()
        return "Est. completion: \(date.formatted(date: .abbreviated, time: .omitted))"
    }
    
    private func updateBookCoverImage(_ newImage: UIImage) {
        book.coverImageData = newImage.jpegData(compressionQuality: 0.8)
        // Optionally force a refresh:
        book = book
    }
}

struct ReadingProgressStyle: ProgressViewStyle {
    func makeBody(configuration: Configuration) -> some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 8)
                .frame(height: 12)
                .foregroundColor(Color(.systemGray5))
            RoundedRectangle(cornerRadius: 8)
                .frame(width: CGFloat(configuration.fractionCompleted ?? 0) * (UIScreen.main.bounds.width - 32), height: 12)
                .foregroundColor(.blue)
                .animation(.easeInOut, value: configuration.fractionCompleted)
        }
    }
}

struct BookDetailView_Previews: PreviewProvider {
    static var previews: some View {
        BookDetailView(
            viewModel: LibraryViewModel(bookRepository: InMemoryRepository()),
            book: Book(
                id: UUID(),
                isbn: "1234567890",
                title: "Sample Book",
                author: "Author",
                year: "2020",
                description: "An adventure",
                genre: "Thriller",
                coverImageUrl: "https://example.com/cover.jpg",
                coverImageData: nil,
                currentPage: 75,
                totalPages: 300
            )
        )
    }
}
