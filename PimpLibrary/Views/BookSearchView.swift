import SwiftUI

struct BookSearchView: View {
    var searchType: BookSearchType
    var onBookFound: (Result<Book, Error>) -> Void

    @Environment(\.presentationMode) var presentationMode
    @State private var query: String = ""
    @State private var errorMessage: String?

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text(searchType == .isbn ? "Search by ISBN" : "Search by Title")
                    .font(.title)
                    .fontWeight(.bold)

                TextField(searchType == .isbn ? "Enter ISBN" : "Enter Title", text: $query)
                    .padding(14)
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color(.systemGray4), lineWidth: 1)
                    )
                    .padding(.horizontal)

                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.footnote)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }

                Button(action: searchBook) {
                    Text("Search")
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(query.isEmpty ? Color.gray : Color.blue)
                        .cornerRadius(12)
                        .padding(.horizontal)
                }
                .disabled(query.isEmpty)

                Spacer()
            }
            .padding(.top, 40)
            .navigationBarTitle(Text("Book Search"), displayMode: .inline)
            .navigationBarItems(trailing: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }

    func searchBook() {
        guard !query.isEmpty else {
            errorMessage = "Please enter a valid \(searchType == .isbn ? "ISBN" : "Title")."
            return
        }

        let selectedAPI = UserDefaults.standard.string(forKey: "selectedAPI") ?? "Google Books"
        let isbnService: IsbnService = (selectedAPI == "Google Books") ? GoogleBookIsbnService() : OpenLibraryIsbnService()

        switch searchType {
        case .isbn:
            isbnService.fetchBookDetails(isbn: query, completion: handleResult)
        case .title:
            isbnService.fetchBookDetails(title: query, completion: handleResult)
        }
    }

    func handleResult(_ result: Result<Book, Error>) {
        switch result {
        case .success:
            onBookFound(result)
            presentationMode.wrappedValue.dismiss()
        case .failure:
            errorMessage = "Could not find the book. Please try again."
        }
    }
}

struct BookSearchView_Previews: PreviewProvider {
    static var previews: some View {
        BookSearchView(searchType: .isbn) { _ in }
    }
}
