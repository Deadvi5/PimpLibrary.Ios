import Foundation

class GoogleBookIsbnService: IsbnService {
    func fetchBookDetails(isbn: String, completion: @escaping (Result<Book, Error>) -> Void) {
        // Costruzione dell'URL per la Google Books API
        let urlString = "https://www.googleapis.com/books/v1/volumes?q=isbn:\(isbn)"
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "GoogleBookIsbnService", code: 0,
                                        userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            // Gestione degli errori di rete
            if let error = error {
                DispatchQueue.main.async { completion(.failure(error)) }
                return
            }
            
            // Verifica della presenza dei dati
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(.failure(NSError(domain: "GoogleBookIsbnService", code: 0,
                                                userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                }
                return
            }
            
            do {
                // Decodifica della risposta JSON
                let bookResponse = try JSONDecoder().decode(GoogleBooksResponse.self, from: data)
                guard let firstItem = bookResponse.items?.first else {
                    DispatchQueue.main.async {
                        completion(.failure(NSError(domain: "GoogleBookIsbnService", code: 404,
                                                    userInfo: [NSLocalizedDescriptionKey: "No book found for this ISBN"])))
                    }
                    return
                }
                
                let volumeInfo = firstItem.volumeInfo
                let title = volumeInfo.title
                let author = volumeInfo.authors?.joined(separator: ", ") ?? "Unknown Author"
                let year = volumeInfo.publishedDate?.prefix(4) ?? "Unknown Year"
                let description = volumeInfo.description ?? "No description available"
                let genre = volumeInfo.categories?.first ?? "Unknown Genre"
                let coverImageUrl = volumeInfo.imageLinks?.thumbnail?
                    .replacingOccurrences(of: "http://", with: "https://") ?? ""
                let totalPages = volumeInfo.pageCount ?? 0
                
                // Creazione dell'oggetto Book, includendo la proprietà isbn
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
