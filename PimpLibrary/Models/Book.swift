//
//  Book.swift
//  PimpLibrary
//
//  Created by Lorenzo Villa on 04/06/24.
//

import Foundation

struct Book: Identifiable {
    var id : UUID
    var title: String
    var author: String
    var year: String
    var description: String
    var genre: String
    var coverImageUrl: String
}
