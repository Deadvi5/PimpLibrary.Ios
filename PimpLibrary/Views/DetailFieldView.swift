import SwiftUI

struct DetailFieldView: View {
    var label: String
    @Binding var text: String
    var isMultiline: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(label)
                .font(.headline)
            if isMultiline {
                TextEditor(text: $text)
                    .padding(8)
                    .background(Color(UIColor.systemBackground))
                    .cornerRadius(8)
                    .foregroundColor(.primary)
                    .frame(height: 150)
            } else {
                TextField(label, text: $text)
                    .padding(8)
                    .background(Color(UIColor.systemBackground))
                    .cornerRadius(8)
                    .foregroundColor(.primary)
            }
        }
    }
}

struct DetailFieldView_Previews: PreviewProvider {
    @State static var sampleText = "Mark"
    static var previews: some View {
        DetailFieldView(label: "Name", text: $sampleText)
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
