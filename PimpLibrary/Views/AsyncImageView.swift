import SwiftUI

struct AsyncImageView: View {
    @StateObject private var loader: ImageUtilities
    private let placeholder: Image

    init(url: URL, placeholder: Image = Image(systemName: "photo")) {
        _loader = StateObject(wrappedValue: ImageUtilities(url: url))
        self.placeholder = placeholder
    }

    var body: some View {
        content.onAppear(perform: loader.load)
    }

    private var content: some View {
        Group {
            if let image = loader.image {
                Image(uiImage: image).resizable()
            } else {
                placeholder
            }
        }
    }
}

struct AsyncImageView_Previews: PreviewProvider {
    static var previews: some View {
        AsyncImageView(url: URL(string: "https://example.com/image.jpg")!)
            .previewLayout(.sizeThatFits)
    }
}
