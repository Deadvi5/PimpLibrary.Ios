import Foundation

/// Classe di utilità per la gestione degli URL.
class URLUtilities {
    /// Modifica lo schema dell'URL in HTTPS.
    /// Se non è possibile ottenere le componenti, ritorna l'URL originale.
    static func changeURLSchemeToHTTPS(url: URL) -> URL {
        guard var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            return url
        }
        components.scheme = "https"
        return components.url ?? url
    }
}
