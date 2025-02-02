import Foundation

class InMemoryRepository: BookRepository {
    private var books: [Book] = [
        Book(
            id: UUID(),
            isbn: "1111111111",
            title: "The Great Adventure",
            author: "Jane Smith",
            year: "2023",
            description: "A thrilling journey through unknown lands",
            genre: "Adventure",
            coverImageUrl: "",
            coverImageData: nil,
            currentPage: 45,
            totalPages: 320
        ),
        Book(
            id: UUID(),
            isbn: "2222222222",
            title: "Swift Programming Guide",
            author: "Apple Inc.",
            year: "2024",
            description: "Comprehensive guide to Swift programming",
            genre: "Technology",
            coverImageUrl: "",
            coverImageData: nil,
            currentPage: 120,
            totalPages: 450
        ),
        Book(
            id: UUID(),
            isbn: "3333333333",
            title: "Mystery of the Ancients",
            author: "Robert Langdon",
            year: "2022",
            description: "Historical mystery spanning continents",
            genre: "Mystery",
            coverImageUrl: "",
            coverImageData: nil,
            currentPage: 0,
            totalPages: 280
        )
    ]
    
    func fetchBooks() -> [Book] {
        return books
    }
    
    func saveBook(book: Book) {
        if let index = books.firstIndex(where: { $0.id == book.id }) {
            books[index] = book
        } else {
            books.append(book)
        }
    }
    
    func removeBook(id: UUID) {
        books.removeAll { $0.id == id }
    }
}
