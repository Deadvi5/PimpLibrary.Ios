//
//  GoogleBookIsbnService.swift
//  PimpLibrary
//
//  Created by Lorenzo Villa on 07/06/24.
//

import Foundation

class GoogleBookIsbnService: IsbnService {
    func fetchBookDetails(isbn: String, completion: @escaping (Result<Book, Error>) -> Void) {
        let urlString = "https://www.googleapis.com/books/v1/volumes?q=isbn:\(isbn)"
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }

            guard let data = data else {
                DispatchQueue.main.async {
                    completion(.failure(NSError(domain: "No data received", code: 0, userInfo: nil)))
                }
                return
            }

            do {
                let bookResponse = try JSONDecoder().decode(GoogleBooksResponse.self, from: data)
                
                if let book = bookResponse.items.first {
                    let title = book.volumeInfo.title
                    let author = book.volumeInfo.authors?.first ?? "Unknown Author"
                    let year = book.volumeInfo.publishedDate?.prefix(4) ?? "Unknown Year"
                    let description = book.volumeInfo.description ?? "Unknown Description"
                    let genre = book.volumeInfo.categories?.first?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "Unknown Genre"
                    let coverImageUrl = (book.volumeInfo.imageLinks?.thumbnail ?? "").replacingOccurrences(of: "http://", with: "https://")

                    let bookDetails = Book(
                        id: UUID(),
                        title: String(title),
                        author: String(author),
                        year: String(year),
                        description: String(description),
                        genre: String(genre),
                        coverImageUrl: String(coverImageUrl)
                    )
                    
                    DispatchQueue.main.async {
                        completion(.success(bookDetails))
                    }
                } else {
                    DispatchQueue.main.async {
                        completion(.failure(NSError(domain: "No book found for this ISBN", code: 0, userInfo: nil)))
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }.resume()
    }
}
