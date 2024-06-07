//
//  BookEntity.swift
//  PimpLibrary
//
//  Created by Lorenzo Villa on 06/06/24.
//

import Foundation
import RealmSwift

class BookEntity: Object, Identifiable {
    @objc dynamic var id: String = UUID().uuidString
    @objc dynamic var title: String = ""
    @objc dynamic var author: String = ""
    @objc dynamic var year: String = ""
    @objc dynamic var bookDescription: String = ""
    @objc dynamic var genre: String = ""
    @objc dynamic var coverImageUrl: String = ""

    override static func primaryKey() -> String? {
        return "id"
    }
}
