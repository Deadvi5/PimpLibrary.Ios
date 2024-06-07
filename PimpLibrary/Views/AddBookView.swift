//
//  AddBookView.swift
//  PimpLibrary
//
//  Created by Lorenzo Villa on 04/06/24.
//

import SwiftUI

struct AddBookView: View {
    @ObservedObject var viewModel: LibraryViewModel
    @State private var title: String = ""
    @State private var author: String = ""
    @State private var year: String = ""
    @State private var genre: String = ""
    @State private var description: String = ""
    @State private var coverImageUrl: String = ""
    
    @State private var showingISBNInput = false
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        HStack {
                            Image(systemName: "chevron.left")
                                .font(.headline)
                            Text("Back")
                                .font(.headline)
                        }
                        .foregroundColor(.blue)
                    }
                    Spacer()
                }
                .padding([.top, .horizontal])
                
                Text("Add Book")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.horizontal)

                Group {
                    DetailFieldView(label: "Title", text: $title)
                    DetailFieldView(label: "Author", text: $author)
                    DetailFieldView(label: "Year", text: $year)
                    DetailFieldView(label: "Genre", text: $genre)
                    DetailFieldView(label: "Description", text: $description, isMultiline: true)
                }
                .padding(.horizontal)

                HStack(spacing: 16) {
                    Button(action: {
                        showingISBNInput = true
                    }) {
                        Text("Input ISBN")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .cornerRadius(10)
                    }

                    Button(action: {
                        viewModel.addBook(title: title, author: author, year: year, genre: genre, description: description, coverImageUrl: coverImageUrl)
                        dismiss()
                    }) {
                        Text("Add")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .padding(.vertical)
        }
        .background(Color(UIColor.systemGroupedBackground))
        .navigationBarHidden(true)
        .sheet(isPresented: $showingISBNInput) {
            IsbnInputView(onBookFound: { foundTitle, foundAuthor, foundYear, foundGenre, foundDescription, foundCoverImage in
                title = foundTitle
                author = foundAuthor
                year = foundYear
                genre = foundGenre
                description = foundDescription
                coverImageUrl = foundCoverImage
            }, isbnService: GoogleBookIsbnService())
        }
    }
}

struct AddBookView_Previews: PreviewProvider {
    static var previews: some View {
        AddBookView(viewModel: LibraryViewModel(bookRepository: InMemoryRepository()))
    }
}
