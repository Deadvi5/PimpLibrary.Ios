//
//  UrlUtilities.swift
//  PimpLibrary
//
//  Created by Lorenzo Villa on 06/06/24.
//

import Foundation

class URLUtilities {
    static func changeURLSchemeToHTTPS(url: URL) -> URL {
        var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)!
        urlComponents.scheme = "https"
        return urlComponents.url ?? url
    }
}
