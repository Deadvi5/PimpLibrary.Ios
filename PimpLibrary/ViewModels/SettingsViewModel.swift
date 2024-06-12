import SwiftUI
import RealmSwift
import UniformTypeIdentifiers

extension UTType {
    static var pimplib: UTType {
        UTType(importedAs: "com.yourcompany.pimplib")
    }
}

class SettingsViewModel: ObservableObject {
    @Published var useGridView: Bool = UserDefaults.standard.bool(forKey: "useGridView")
    @Published var exportedFile: ExportedFile? = nil

    func toggleUseGridView() {
        useGridView.toggle()
        UserDefaults.standard.set(useGridView, forKey: "useGridView")
    }

    func deleteRealmFile() {
        if let realmURL = Realm.Configuration.defaultConfiguration.fileURL {
            let realmURLs = [
                realmURL,
                realmURL.appendingPathExtension("lock"),
                realmURL.appendingPathExtension("note"),
                realmURL.appendingPathExtension("management")
            ]
            
            for url in realmURLs {
                do {
                    try FileManager.default.removeItem(at: url)
                    print("Deleted Realm file at: \(url)")
                } catch {
                    print("Failed to delete Realm file: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func exportBooks() {
        let realm = try! Realm()
        let books = realm.objects(BookEntity.self)
        let booksArray = Array(books)
        let jsonEncoder = JSONEncoder()
        
        do {
            let jsonData = try jsonEncoder.encode(booksArray)
            exportedFile = ExportedFile(data: jsonData)
        } catch {
            print("Failed to encode books to JSON: \(error.localizedDescription)")
        }
    }
    
    func importBooks(from url: URL, completion: @escaping (Bool) -> Void) {
        do {
            let isAccessing = url.startAccessingSecurityScopedResource()
            defer {
                if isAccessing {
                    url.stopAccessingSecurityScopedResource()
                }
            }

            let jsonData = try Data(contentsOf: url)
            let jsonDecoder = JSONDecoder()
            let books = try jsonDecoder.decode([BookEntity].self, from: jsonData)
            
            let realm = try! Realm()
            try realm.write {
                realm.delete(realm.objects(BookEntity.self))
                realm.add(books)
            }
            completion(true)
        } catch {
            print("Failed to import books from JSON: \(error.localizedDescription)")
            completion(false)
        }
    }
}

struct ExportedFile: FileDocument {
    static var readableContentTypes: [UTType] { [.pimplib] }
    
    var data: Data
    
    init(data: Data) {
        self.data = data
    }
    
    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents else {
            throw CocoaError(.fileReadCorruptFile)
        }
        self.data = data
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        return FileWrapper(regularFileWithContents: data)
    }
}
