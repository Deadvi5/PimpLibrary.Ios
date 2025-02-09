import SwiftUI

struct IsbnInputView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var isbn: String = ""
    @State private var errorMessage: String?
    @State private var showingBarcodeScanner = false
    var onBookFound: (String, String, String, String, String, String, Int) -> Void
    var isbnService: IsbnService

    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                Text("Search for a Book")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.top, 40)

                Text("Enter ISBN manually or scan the barcode to find your book.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                HStack(spacing: 12) {
                    TextField("Enter ISBN", text: $isbn)
                        .padding(14)
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        .keyboardType(.numberPad)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color(.systemGray4), lineWidth: 1)
                        )

                    Button(action: { showingBarcodeScanner = true }) {
                        Image(systemName: "camera.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.blue)
                            .clipShape(Circle())
                            .shadow(radius: 4)
                    }
                }
                .padding(.horizontal)

                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.footnote)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }

                Button(action: searchBook) {
                    Text("Search Book")
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(isbn.isEmpty ? Color.gray : Color.blue)
                        .cornerRadius(12)
                        .padding(.horizontal)
                        .shadow(radius: 4)
                }
                .disabled(isbn.isEmpty)

                Spacer()
            }
            .padding(.bottom, 40)
            .navigationBarTitle("ISBN Search", displayMode: .inline)
            .navigationBarItems(trailing: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            })
            .sheet(isPresented: $showingBarcodeScanner) {
                BarcodeScannerView(isbn: $isbn)
            }
        }
    }

    func searchBook() {
        guard !isbn.isEmpty else {
            errorMessage = "Please enter a valid ISBN."
            return
        }
        
        let formattedISBN = isbn.trimmingCharacters(in: .whitespacesAndNewlines)
        isbnService.fetchBookDetails(isbn: formattedISBN) { result in
            switch result {
            case .success(let bookDetails):
                onBookFound(
                    bookDetails.title,
                    bookDetails.author,
                    bookDetails.year,
                    bookDetails.genre,
                    bookDetails.description,
                    bookDetails.coverImageUrl,
                    bookDetails.totalPages
                )
                presentationMode.wrappedValue.dismiss()
            case .failure(let error):
                self.errorMessage = "Could not find the book. Please check the ISBN or try again later."
                print("Error fetching book details: \(error.localizedDescription)")
            }
        }
    }
}

struct IsbnInputView_Previews: PreviewProvider {
    static var previews: some View {
        IsbnInputView(onBookFound: { _, _, _, _, _, _, _ in }, isbnService: OpenLibraryIsbnService())
    }
}
