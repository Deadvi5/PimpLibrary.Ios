import Foundation

struct GoogleBooksResponse: Codable {
    let items: [GoogleBookItem]?
}

struct GoogleBookItem: Codable {
    let volumeInfo: GoogleVolumeInfo
}

struct GoogleVolumeInfo: Codable {
    let title: String
    let authors: [String]?
    let publishedDate: String?
    let description: String?
    let categories: [String]?
    let pageCount: Int?
    let imageLinks: ImageLinks?
}

struct ImageLinks: Codable {
    let thumbnail: String?
}
