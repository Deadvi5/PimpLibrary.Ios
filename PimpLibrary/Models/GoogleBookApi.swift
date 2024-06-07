//
//  GoogleBookApi.swift
//  PimpLibrary
//
//  Created by Lorenzo Villa on 06/06/24.
//

import Foundation

struct GoogleBooksResponse: Codable {
    let items: [GoogleBookItem]
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
    let imageLinks: ImageLinks?
}

struct ImageLinks: Codable {
    let thumbnail: String?
}
