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

    override static func primaryKey() -> String? {
        return "id"
    }
    
    enum CodingKeys: String, CodingKey {
        case id, title, author, year, bookDescription, genre, coverImageUrl
    }
}
