//
//  RealmBookRepository.swift
//  PimpLibrary
//
//  Created by Lorenzo Villa on 07/06/24.
//

import Foundation
import RealmSwift

class RealmBookRepository : BookRepository {
    
    init() {
        configureRealm()
    }
    
    private func configureRealm() {
        let config = Realm.Configuration(
            schemaVersion: 2,
            migrationBlock: { migration, oldSchemaVersion in
                if oldSchemaVersion < 1 {
                }
            })
        
        Realm.Configuration.defaultConfiguration = config
    }
    
    func deleteRealmFile() {
        if let realmURL = Realm.Configuration.defaultConfiguration.fileURL {
            let realmURLs = [
                realmURL,
                realmURL.appendingPathExtension("lock"),
                realmURL.appendingPathExtension("note"),
                realmURL.appendingPathExtension("management")
            ]
            
            for url in realmURLs {
                do {
                    try FileManager.default.removeItem(at: url)
                    print("Deleted Realm file at: \(url)")
                } catch {
                    print("Failed to delete Realm file: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func saveBook(book: Book) {
        let realm = try! Realm()
        
        try! realm.write {
            if let existingBookEntity = realm.object(ofType: BookEntity.self, forPrimaryKey: book.id.uuidString) {
                existingBookEntity.title = book.title
                existingBookEntity.author = book.author
                existingBookEntity.year = book.year
                existingBookEntity.bookDescription = book.description
                existingBookEntity.genre = book.genre
                existingBookEntity.coverImageUrl = book.coverImageUrl
                existingBookEntity.coverImageData = book.coverImageData
            } else {
                let bookEntity = BookEntity()
                bookEntity.id = book.id.uuidString
                bookEntity.title = book.title
                bookEntity.author = book.author
                bookEntity.year = book.year
                bookEntity.bookDescription = book.description
                bookEntity.genre = book.genre
                bookEntity.coverImageUrl = book.coverImageUrl
                bookEntity.coverImageData = book.coverImageData
                realm.add(bookEntity)
            }
        }
    }
    
    func removeBook(id: UUID) {
        let realm = try! Realm()
        if let bookToDelete = realm.object(ofType: BookEntity.self, forPrimaryKey: id.uuidString) {
            try! realm.write {
                realm.delete(bookToDelete)
            }
        }
    }

    func fetchBooks() -> [Book] {
        let realm = try! Realm()
        let bookEntities = realm.objects(BookEntity.self)
        
        var books:[Book] = []
        
        for bookEntity in bookEntities {
            let book = Book(id: UUID(uuidString: bookEntity.id)!, title: bookEntity.title, author: bookEntity.author, year: bookEntity.year, description: bookEntity.bookDescription, genre: bookEntity.genre, coverImageUrl: bookEntity.coverImageUrl, coverImageData: bookEntity.coverImageData)
            books.append(book)
        }
        
        return books
    }
}
