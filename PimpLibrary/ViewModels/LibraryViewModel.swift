import SwiftUI

class LibraryViewModel: ObservableObject {
    @Published var books: [Book]
    let bookRepository: BookRepository

    init(bookRepository: BookRepository) {
        self.bookRepository = bookRepository
        self.books = bookRepository.fetchBooks()
    }
    
    /// Aggiunge un nuovo libro alla libreria.
    /// Se `isbn` non viene passato, viene impostata una stringa vuota.
    func addBook(
        isbn: String = "",
        title: String,
        author: String,
        year: String,
        genre: String,
        description: String,
        coverImageUrl: String,
        coverImageData: Data?,
        currentPage: Int = 0,
        totalPages: Int = 0
    ) {
        guard !title.isEmpty else { return }
        
        let newBook = Book(
            id: UUID(),
            isbn: isbn,
            title: title,
            author: author,
            year: year,
            description: description,
            genre: genre,
            coverImageUrl: coverImageUrl,
            coverImageData: coverImageData,
            currentPage: currentPage,
            totalPages: totalPages
        )
        books.append(newBook)
        bookRepository.saveBook(book: newBook)
    }
    
    /// Modifica le informazioni di un libro esistente.
    /// Se il parametro `isbn` è vuoto, viene preservato il valore già presente.
    func editBook(
        book: Book,
        isbn: String = "",
        title: String,
        author: String,
        year: String,
        genre: String,
        description: String,
        coverImageData: Data?,
        currentPage: Int,
        totalPages: Int
    ) {
        guard let index = books.firstIndex(where: { $0.id == book.id }) else { return }
        let updatedIsbn = isbn.isEmpty ? book.isbn : isbn
        let updatedBook = Book(
            id: book.id,
            isbn: updatedIsbn,
            title: title,
            author: author,
            year: year,
            description: description,
            genre: genre,
            coverImageUrl: book.coverImageUrl, // Preservo l'URL esistente
            coverImageData: coverImageData,
            currentPage: currentPage,
            totalPages: totalPages
        )
        books[index] = updatedBook
        bookRepository.saveBook(book: updatedBook)
    }
    
    /// Rimuove un libro dalla libreria.
    func removeBook(book: Book) {
        guard let index = books.firstIndex(where: { $0.id == book.id }) else { return }
        books.remove(at: index)
        bookRepository.removeBook(id: book.id)
    }
    
    /// Aggiorna il progresso di lettura di un libro.
    func updateReadingProgress(for book: Book, currentPage: Int) {
        guard let index = books.firstIndex(where: { $0.id == book.id }) else { return }
        var updatedBook = books[index]
        updatedBook.currentPage = currentPage
        books[index] = updatedBook
        bookRepository.saveBook(book: updatedBook)
    }
    
    /// Restituisce il progresso di lettura (valore frazionario) di un libro.
    func getProgress(for book: Book) -> Double {
        guard book.totalPages > 0 else { return 0 }
        return Double(book.currentPage) / Double(book.totalPages)
    }
    
    func updateBookProgress(book: Book, currentPage: Int, totalPages: Int) {
        guard let index = books.firstIndex(where: { $0.id == book.id }) else { return }
        books[index].currentPage = currentPage
        books[index].totalPages = totalPages
        bookRepository.saveBook(book: books[index])
    }
}
