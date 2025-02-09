import Foundation

class OpenLibraryIsbnService: IsbnService {
    func fetchBookDetails(isbn: String, completion: @escaping (Result<Book, Error>) -> Void) {
        // Endpoint dell'API Open Library; la risposta è un dizionario con chiave "ISBN:<isbn>"
        let urlString = "https://openlibrary.org/api/books?bibkeys=ISBN:\(isbn)&jscmd=data&format=json"
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "OpenLibraryIsbnService", code: 0,
                                        userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            // Gestione degli errori di connessione
            if let error = error {
                DispatchQueue.main.async { completion(.failure(error)) }
                return
            }
            
            // Verifica che i dati siano stati ricevuti
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(.failure(NSError(domain: "OpenLibraryIsbnService", code: 0,
                                                userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                }
                return
            }
            
            do {
                // Parsing della risposta JSON
                guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                      let bookData = json["ISBN:\(isbn)"] as? [String: Any] else {
                    DispatchQueue.main.async {
                        completion(.failure(NSError(domain: "OpenLibraryIsbnService", code: 404,
                                                    userInfo: [NSLocalizedDescriptionKey: "No book found for this ISBN"])))
                    }
                    return
                }
                
                // Estrazione dei dettagli basilari
                let title = bookData["title"] as? String ?? "No Title"
                
                var author = "Unknown Author"
                if let authorsArray = bookData["authors"] as? [[String: Any]] {
                    let authorNames = authorsArray.compactMap { $0["name"] as? String }
                    if !authorNames.isEmpty {
                        author = authorNames.joined(separator: ", ")
                    }
                }
                
                let publishDate = bookData["publish_date"] as? String ?? "Unknown Year"
                let year = String(publishDate.prefix(4))
                
                var descriptionText = "No description available"
                if let desc = bookData["description"] as? String {
                    descriptionText = desc
                } else if let descDict = bookData["description"] as? [String: Any],
                          let descValue = descDict["value"] as? String {
                    descriptionText = descValue
                }
                
                var genre = "Unknown Genre"
                if let subjects = bookData["subjects"] as? [[String: Any]],
                   let firstSubject = subjects.first,
                   let subjectName = firstSubject["name"] as? String {
                    genre = subjectName
                }
                
                var coverImageUrl = ""
                if let cover = bookData["cover"] as? [String: Any] {
                    coverImageUrl = cover["medium"] as? String ?? cover["small"] as? String ?? cover["large"] as? String ?? ""
                }
                
                let totalPages = bookData["number_of_pages"] as? Int ?? 0
                
                // Creazione dell'oggetto Book con la proprietà isbn
                let bookDetails = Book(
                    id: UUID(),
                    isbn: isbn,
                    title: title,
                    author: author,
                    year: year,
                    description: descriptionText,
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
    
    func fetchBookDetails(title: String, completion: @escaping (Result<Book, Error>) -> Void) {
            let encodedTitle = title.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? title
            let urlString = "https://openlibrary.org/search.json?title=\(encodedTitle)"
            guard let url = URL(string: urlString) else {
                completion(.failure(NSError(domain: "OpenLibraryIsbnService", code: 0,
                                            userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
                return
            }
            
            URLSession.shared.dataTask(with: url) { data, response, error in
                if let error = error {
                    DispatchQueue.main.async { completion(.failure(error)) }
                    return
                }
                
                guard let data = data else {
                    DispatchQueue.main.async {
                        completion(.failure(NSError(domain: "OpenLibraryIsbnService", code: 0,
                                                    userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                    }
                    return
                }
                
                do {
                    let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                    guard let docs = jsonResponse?["docs"] as? [[String: Any]], let firstDoc = docs.first else {
                        DispatchQueue.main.async {
                            completion(.failure(NSError(domain: "OpenLibraryIsbnService", code: 404,
                                                        userInfo: [NSLocalizedDescriptionKey: "No book found for this title"])))
                        }
                        return
                    }
                    
                    let bookDetails = Book(
                        id: UUID(),
                        isbn: (firstDoc["isbn"] as? [String])?.first ?? "Unknown ISBN",
                        title: firstDoc["title"] as? String ?? "No Title",
                        author: (firstDoc["author_name"] as? [String])?.joined(separator: ", ") ?? "Unknown Author",
                        year: String((firstDoc["first_publish_year"] as? Int) ?? 0),
                        description: firstDoc["subtitle"] as? String ?? "No description available",
                        genre: (firstDoc["subject"] as? [String])?.first ?? "Unknown Genre",
                        coverImageUrl: firstDoc["cover_i"].flatMap { "https://covers.openlibrary.org/b/id/\($0)-M.jpg" } ?? "",
                        coverImageData: nil,
                        currentPage: 0,
                        totalPages: firstDoc["number_of_pages_median"] as? Int ?? 0
                    )
                    
                    DispatchQueue.main.async { completion(.success(bookDetails)) }
                } catch {
                    DispatchQueue.main.async { completion(.failure(error)) }
                }
            }.resume()
        }
}
