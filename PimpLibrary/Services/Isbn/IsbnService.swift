//
//  IsbnService.swift
//  PimpLibrary
//
//  Created by Lorenzo Villa on 07/06/24.
//

import Foundation

protocol IsbnService {
    func fetchBookDetails(isbn: String, completion: @escaping (Result<Book, Error>) -> Void)
}
