//
//  ImageLoader.swift
//  PimpLibrary
//
//  Created by Lorenzo Villa on 06/06/24.
//

import Foundation
import SwiftUI

class ImageUtilities: ObservableObject {
    @Published var image: UIImage?
    private var url: URL

    init(url: URL) {
        self.url = URLUtilities.changeURLSchemeToHTTPS(url: url)
    }

    func load() {
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, let uiImage = UIImage(data: data) else { return }
            DispatchQueue.main.async {
                self.image = uiImage
            }
        }.resume()
    }
}
