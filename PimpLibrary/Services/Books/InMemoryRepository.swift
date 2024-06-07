//
//  InMemoryRepository.swift
//  PimpLibrary
//
//  Created by Lorenzo Villa on 07/06/24.
//

import Foundation

class InMemoryRepository: BookRepository {
    private var books: [Book] = []
    
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
