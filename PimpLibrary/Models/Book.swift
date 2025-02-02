import Foundation

struct Book: Identifiable, Equatable {
    let id: UUID
    let isbn: String
    var title: String
    var author: String
    var year: String
    var description: String
    var genre: String
    var coverImageUrl: String
    var coverImageData: Data?
    var currentPage: Int
    var totalPages: Int
}
