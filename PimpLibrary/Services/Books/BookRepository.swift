//
//  BookRepository.swift
//  PimpLibrary
//
//  Created by Lorenzo Villa on 07/06/24.
//

import Foundation

protocol BookRepository {
    func fetchBooks() -> [Book]
    func saveBook(book: Book)
    func removeBook(id: UUID)
}
