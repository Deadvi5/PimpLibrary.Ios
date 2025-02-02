import SwiftUI

struct SearchBarView: View {
    @Binding var text: String

    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
            TextField("Search books by title", text: $text)
                .padding(.horizontal, 5)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocapitalization(.none)
                .disableAutocorrection(true)
            if !text.isEmpty {
                Button(action: { text = "" }) {
                    Image(systemName: "xmark.circle.fill")
                }
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
    }
}

struct SearchBar_Previews: PreviewProvider {
    @State static var sampleText = "Mark"
    static var previews: some View {
        SearchBarView(text: $sampleText)
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
