//
//  DetailFieldView.swift
//  PimpLibrary
//
//  Created by Lorenzo Villa on 07/06/24.
//

import SwiftUI

struct DetailFieldView: View {
    var label: String
    @Binding var text: String
    var isMultiline: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.headline)
            if isMultiline {
                TextEditor(text: $text)
                    .frame(height: 100)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                    )
            } else {
                TextField(label, text: $text)
                    .padding(10)
                    .background(Color.white)
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                    )
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
