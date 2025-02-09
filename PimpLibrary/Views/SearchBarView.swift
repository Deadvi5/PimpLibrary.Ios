import SwiftUI

struct SearchBarView: View {
    @Binding var text: String

    var body: some View {
        HStack {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                    .padding(.leading, 8)

                TextField("Search books by title", text: $text)
                    .foregroundColor(.primary)
                    .padding(10)
                    .background(Color.clear)
                    .disableAutocorrection(true)
                    .autocapitalization(.none)

                if !text.isEmpty {
                    Button(action: { text = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                    .padding(.trailing, 8)
                    .transition(.scale)
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray6))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color(.systemGray4), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 2)
        }
        .animation(.easeInOut, value: text)
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
