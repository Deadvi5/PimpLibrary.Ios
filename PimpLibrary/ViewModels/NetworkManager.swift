import Foundation

class NetworkManager {
    static let shared = NetworkManager()

    func fetchBooks(query: String, completion: @escaping (Result<[Book], Error>) -> Void) {
        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let urlString = "https://www.googleapis.com/books/v1/volumes?q=\(encodedQuery)"
        guard let url = URL(string: urlString) else { return }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else { return }

            do {
                let googleBooksResponse = try JSONDecoder().decode(GoogleBooksResponse.self, from: data)
                let books = googleBooksResponse.items.map { item in
                    Book(
                        title: item.volumeInfo.title,
                        author: item.volumeInfo.authors?.joined(separator: ", ") ?? "Unknown Author",
                        year: item.volumeInfo.publishedDate ?? "No date",
                        description: item.volumeInfo.description ?? "No Description",
                        genre: item.volumeInfo.mainCategory ?? "No Genre",
                        coverImageUrl: item.volumeInfo.imageLinks?.thumbnail ?? ""
                    )
                }
                completion(.success(books))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}
