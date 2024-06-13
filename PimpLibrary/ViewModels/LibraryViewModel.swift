//
//  LibraryViewModel.swift
//  PimpLibrary
//
//  Created by Lorenzo Villa on 04/06/24.
//

import SwiftUI
import CoreData

class LibraryViewModel: ObservableObject {
    @Published var books: [Book]
    var bookRepository: BookRepository
    
    init(bookRepository: BookRepository) {
            self.bookRepository = bookRepository
            self.books = bookRepository.fetchBooks()
        }
    
    func addBook(title: String, author: String, year: String, genre: String, description: String, coverImageUrl: String, coverImageData: Data?) {
        guard !title.isEmpty else { return }
        
        let newBook = Book(id: UUID(), title: title, author: author, year: year, description: description, genre: genre, coverImageUrl: coverImageUrl, coverImageData: coverImageData)
        books.append(newBook)
        bookRepository.saveBook(book: newBook)
    }
    
    func editBook(book: Book, title: String, author: String, year: String, genre: String, description: String, bookCoverImageData: Data?) {
        if let index = books.firstIndex(where: { $0.id == book.id }) {
            books[index].title = title
            books[index].author = author
            books[index].year = year
            books[index].genre = genre
            books[index].description = description
            books[index].coverImageData = bookCoverImageData
            bookRepository.saveBook(book: books[index])
        }
    }
    
    func removeBook(book: Book) {
        if let index = books.firstIndex(where: { $0.id == book.id }) {
            books.remove(at: index)
            bookRepository.removeBook(id: book.id)
        }
    }
}
