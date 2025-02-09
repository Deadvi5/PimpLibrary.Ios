import Foundation

/// Protocollo per il recupero dei dettagli di un libro tramite ISBN.
protocol IsbnService {
    func fetchBookDetails(isbn: String, completion: @escaping (Result<Book, Error>) -> Void)
    func fetchBookDetails(title: String, completion: @escaping (Result<Book, Error>) -> Void)  // Nuovo metodo
}
