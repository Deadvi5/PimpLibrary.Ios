//
//  AsyncImageView.swift
//  PimpLibrary
//
//  Created by Lorenzo Villa on 05/06/24.
//

import SwiftUI

struct AsyncImageView: View {
    @StateObject private var loader: ImageUtilities
    private let placeholder: Image

    init(url: URL, placeholder: Image = Image(systemName: "photo")) {
        _loader = StateObject(wrappedValue: ImageUtilities(url: url))
        self.placeholder = placeholder
    }

    var body: some View {
        content
            .onAppear(perform: loader.load)
    }

    private var content: some View {
        Group {
            if let image = loader.image {
                Image(uiImage: image)
                    .resizable()
            } else {
                placeholder
            }
        }
    }
}
