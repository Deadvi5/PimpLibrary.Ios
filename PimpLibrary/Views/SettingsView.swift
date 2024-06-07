//
//  SettingsView.swift
//  PimpLibrary
//
//  Created by Lorenzo Villa on 07/06/24.
//

import SwiftUI

import SwiftUI

struct SettingsView: View {
    var body: some View {
        NavigationView {
            Text("Settings")
                .font(.largeTitle)
                .navigationBarTitle("Settings", displayMode: .inline)
        }
    }
}

#Preview {
    SettingsView()
}
