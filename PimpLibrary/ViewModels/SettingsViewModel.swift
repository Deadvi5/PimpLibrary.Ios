//
//  SettingsViewModel.swift
//  PimpLibrary
//
//  Created by Lorenzo Villa on 07/06/24.
//

import SwiftUI
import RealmSwift

class SettingsViewModel: ObservableObject {
    @Published var useGridView: Bool = UserDefaults.standard.bool(forKey: "useGridView")

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
}
