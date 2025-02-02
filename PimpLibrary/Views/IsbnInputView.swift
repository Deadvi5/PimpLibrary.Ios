import SwiftUI

struct IsbnInputView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var isbn: String = ""
    @State private var errorMessage: String?
    @State private var showingBarcodeScanner = false
    var onBookFound: (String, String, String, String, String, String) -> Void
    var isbnService: IsbnService

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Enter ISBN to Search for a Book")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                    .padding(.top, 40)
                
                HStack(spacing: 10) {
                    TextField("ISBN", text: $isbn)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(10)
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        .keyboardType(.numberPad)
                    
                    Button(action: { showingBarcodeScanner = true }) {
                        Image(systemName: "camera")
                            .font(.title)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                }
                .padding(.horizontal)
                
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding(.horizontal)
                }
                
                Button(action: searchBook) {
                    Text("Search")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(10)
                        .padding(.horizontal)
                }
                
                Spacer()
            }
            .padding()
            .navigationBarTitle("Search Book by ISBN", displayMode: .inline)
            .navigationBarItems(trailing: Button("Cancel") { presentationMode.wrappedValue.dismiss() })
            .sheet(isPresented: $showingBarcodeScanner) {
                BarcodeScannerView(isbn: $isbn)
            }
        }
    }
    
    func searchBook() {
        guard !isbn.isEmpty else {
            errorMessage = "Please enter a valid ISBN"
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
                    bookDetails.coverImageUrl
                )
                presentationMode.wrappedValue.dismiss()
            case .failure(let error):
                self.errorMessage = "Error fetching book details: \(error.localizedDescription)"
            }
        }
    }
}

struct IsbnInputView_Previews: PreviewProvider {
    static var previews: some View {
        IsbnInputView(onBookFound: { _,_,_,_,_,_ in }, isbnService: OpenLibraryIsbnService())
    }
}
