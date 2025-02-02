import Foundation
import RealmSwift

class BookEntity: Object, Identifiable, Codable {
    @objc dynamic var id: String = UUID().uuidString
    @objc dynamic var title: String = ""
    @objc dynamic var author: String = ""
    @objc dynamic var year: String = ""
    @objc dynamic var bookDescription: String = ""
    @objc dynamic var genre: String = ""
    @objc dynamic var coverImageUrl: String = ""
    @objc dynamic var coverImageData: Data?
    @objc dynamic var currentPage: Int = 0
    @objc dynamic var totalPages: Int = 0
    @objc dynamic var isbn: String = "" // Nuova proprietà per ISBN

    override static func primaryKey() -> String? {
        return "id"
    }
}
