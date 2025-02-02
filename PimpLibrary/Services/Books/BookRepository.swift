import Foundation

/// Protocollo per il repository dei libri.
protocol BookRepository {
    /// Recupera la lista dei libri.
    func fetchBooks() -> [Book]
    /// Salva o aggiorna un libro.
    func saveBook(book: Book)
    /// Rimuove un libro identificato dal suo UUID.
    func removeBook(id: UUID)
}
