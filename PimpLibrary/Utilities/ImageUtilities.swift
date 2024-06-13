//
//  ImageLoader.swift
//  PimpLibrary
//
//  Created by Lorenzo Villa on 06/06/24.
//

import Foundation
import SwiftUI
import CoreImage
import UIKit

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
    
    static func cropBookCover(from image: UIImage) -> UIImage? {
        guard let ciImage = CIImage(image: image) else { return nil }

        let detector = CIDetector(ofType: CIDetectorTypeRectangle, context: nil, options: [CIDetectorAccuracy: CIDetectorAccuracyHigh])
        let features = detector?.features(in: ciImage) as? [CIRectangleFeature]

        if let feature = features?.first {
            let croppedCIImage = ciImage.cropped(to: feature.bounds)
            let context = CIContext()
            
            if let cgImage = context.createCGImage(croppedCIImage, from: croppedCIImage.extent) {
                let croppedUIImage = UIImage(cgImage: cgImage, scale: image.scale, orientation: image.imageOrientation)
                return croppedUIImage
            }
        }
        return nil
    }
}
