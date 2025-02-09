import Foundation

class ISBNdbService: IsbnService {
    private let apiKey = "YOUR_REST_KEY" // Replace with your actual ISBNdb API key

    func fetchBookDetails(isbn: String, completion: @escaping (Result<Book, Error>) -> Void) {
        // Construct the URL for the ISBNdb API
        let urlString = "https://api2.isbndb.com/book/\(isbn)"
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "ISBNdbService", code: 0,
                                        userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }

        // Create a URLRequest and set the Authorization header
        var request = URLRequest(url: url)
        request.setValue(apiKey, forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, response, error in
            // Handle network errors
            if let error = error {
                DispatchQueue.main.async { completion(.failure(error)) }
                return
            }

            // Verify the presence of data
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(.failure(NSError(domain: "ISBNdbService", code: 0,
                                                userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                }
                return
            }

            do {
                // Decode the JSON response
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let bookResponse = try decoder.decode(ISBNdbBookResponse.self, from: data)
                let bookData = bookResponse.book

                // Extract book details
                let title = bookData.title
                let author = bookData.authors?.joined(separator: ", ") ?? "Unknown Author"
                let year = bookData.datePublished?.prefix(4) ?? "Unknown Year"
                let description = bookData.synopsys ?? "No description available"
                let genre = bookData.subjects?.first ?? "Unknown Genre"
                let coverImageUrl = bookData.image ?? ""
                let totalPages = bookData.pages ?? 0

                // Create the Book object, including the isbn property
                let bookDetails = Book(
                    id: UUID(),
                    isbn: isbn,
                    title: title,
                    author: author,
                    year: String(year),
                    description: description,
                    genre: genre,
                    coverImageUrl: coverImageUrl,
                    coverImageData: nil,
                    currentPage: 0,
                    totalPages: totalPages
                )

                DispatchQueue.main.async { completion(.success(bookDetails)) }
            } catch {
                DispatchQueue.main.async { completion(.failure(error)) }
            }
        }.resume()
    }
}

// Define the response structures based on the ISBNdb API documentation
struct ISBNdbBookResponse: Codable {
    let book: ISBNdbBook
}

struct ISBNdbBook: Codable {
    let title: String
    let authors: [String]?
    let datePublished: String?
    let synopsys: String?
    let subjects: [String]?
    let image: String?
    let pages: Int?
}
