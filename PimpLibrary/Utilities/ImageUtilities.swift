import Foundation
import SwiftUI
import CoreImage
import UIKit

/// Classe di utilità per il caricamento e la manipolazione delle immagini.
class ImageUtilities: ObservableObject {
    @Published var image: UIImage?
    private var url: URL

    /// Inizializza con un URL, convertendo il relativo schema in HTTPS.
    init(url: URL) {
        self.url = URLUtilities.changeURLSchemeToHTTPS(url: url)
    }

    /// Carica l'immagine da rete e aggiorna la proprietà pubblicata `image`.
    func load() {
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error loading image: \(error.localizedDescription)")
                return
            }
            guard let data = data, let uiImage = UIImage(data: data) else {
                print("Failed to load image from data.")
                return
            }
            DispatchQueue.main.async {
                self.image = uiImage
            }
        }.resume()
    }
    
    /// Ritaglia l'immagine individuando il primo rettangolo (ad es. la copertina di un libro)
    /// utilizzando CIDetector.
    static func cropBookCover(from image: UIImage) -> UIImage? {
        guard let ciImage = CIImage(image: image) else { return nil }
        
        let detectorOptions = [CIDetectorAccuracy: CIDetectorAccuracyHigh]
        let detector = CIDetector(ofType: CIDetectorTypeRectangle, context: nil, options: detectorOptions)
        let features = detector?.features(in: ciImage) as? [CIRectangleFeature]
        
        if let feature = features?.first {
            let croppedCIImage = ciImage.cropped(to: feature.bounds)
            let context = CIContext()
            if let cgImage = context.createCGImage(croppedCIImage, from: croppedCIImage.extent) {
                return UIImage(cgImage: cgImage, scale: image.scale, orientation: image.imageOrientation)
            }
        }
        return nil
    }
}
