import Foundation
import RealmSwift

class RealmBookRepository: BookRepository {
    
    init() {
        configureRealm()
    }
    
    /// Configura Realm con una versione aggiornata dello schema per includere la proprietà `isbn`
    private func configureRealm() {
        let config = Realm.Configuration(
            schemaVersion: 4, // Versione incrementata per includere 'isbn'
            migrationBlock: { migration, oldSchemaVersion in
                if oldSchemaVersion < 4 {
                    migration.enumerateObjects(ofType: BookEntity.className()) { oldObject, newObject in
                        newObject?["currentPage"] = oldObject?["currentPage"] ?? 0
                        newObject?["totalPages"] = oldObject?["totalPages"] ?? 0
                        // Se la proprietà `isbn` non esiste, impostala come stringa vuota
                        if newObject?["isbn"] == nil {
                            newObject?["isbn"] = ""
                        }
                    }
                }
            })
        
        Realm.Configuration.defaultConfiguration = config
    }
    
    /// Metodo per cancellare i file di Realm (utile per debug)
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
                // Aggiorna le proprietà dell'entità esistente
                existingBookEntity.title = book.title
                existingBookEntity.author = book.author
                existingBookEntity.year = book.year
                existingBookEntity.bookDescription = book.description
                existingBookEntity.genre = book.genre
                existingBookEntity.coverImageUrl = book.coverImageUrl
                existingBookEntity.coverImageData = book.coverImageData
                existingBookEntity.currentPage = book.currentPage
                existingBookEntity.totalPages = book.totalPages
                existingBookEntity.isbn = book.isbn
            } else {
                // Crea una nuova entità per il libro
                let bookEntity = BookEntity()
                bookEntity.id = book.id.uuidString
                bookEntity.isbn = book.isbn
                bookEntity.title = book.title
                bookEntity.author = book.author
                bookEntity.year = book.year
                bookEntity.bookDescription = book.description
                bookEntity.genre = book.genre
                bookEntity.coverImageUrl = book.coverImageUrl
                bookEntity.coverImageData = book.coverImageData
                bookEntity.currentPage = book.currentPage
                bookEntity.totalPages = book.totalPages
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
        var books: [Book] = []
        
        for bookEntity in bookEntities {
            let book = Book(
                id: UUID(uuidString: bookEntity.id)!,
                isbn: bookEntity.isbn,
                title: bookEntity.title,
                author: bookEntity.author,
                year: bookEntity.year,
                description: bookEntity.bookDescription,
                genre: bookEntity.genre,
                coverImageUrl: bookEntity.coverImageUrl,
                coverImageData: bookEntity.coverImageData,
                currentPage: bookEntity.currentPage,
                totalPages: bookEntity.totalPages
            )
            books.append(book)
        }
        
        return books
    }
}
