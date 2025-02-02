import SwiftUI

struct ReadingProgressView: View {
    let currentPage: Int
    let totalPages: Int

    var body: some View {
        if totalPages > 0 {
            VStack(alignment: .leading, spacing: 2) {
                ProgressView(value: Float(currentPage), total: Float(totalPages))
                    .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                Text("\(currentPage)/\(totalPages) pages")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
    }
}

struct ReadingProgressView_Previews: PreviewProvider {
    static var previews: some View {
        ReadingProgressView(currentPage: 50, totalPages: 200)
            .padding()
            .previewLayout(.sizeThatFits)
    }
}
