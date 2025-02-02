import Foundation

/// Protocollo per il recupero dei dettagli di un libro tramite ISBN.
protocol IsbnService {
    /// Recupera i dettagli del libro a partire dall'ISBN.
    /// - Parameters:
    ///   - isbn: Il codice ISBN del libro.
    ///   - completion: Chiusura che restituisce un `Book` in caso di successo o un `Error` in caso di fallimento.
    func fetchBookDetails(isbn: String, completion: @escaping (Result<Book, Error>) -> Void)
}
