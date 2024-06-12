import SwiftUI

struct BookDetailView: View {
    @ObservedObject var viewModel: LibraryViewModel
    @State var book: Book
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 15) {
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
                
                Text("Edit Book")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.horizontal)

                Group {
                    DetailFieldView(label: "Title", text: $book.title)
                    DetailFieldView(label: "Author", text: $book.author)
                    DetailFieldView(label: "Year", text: $book.year)
                    DetailFieldView(label: "Genre", text: $book.genre)
                    DetailFieldView(label: "Description", text: $book.description, isMultiline: true)
                }
                .padding(.horizontal)

                Spacer()
                
                Button(action: {
                    viewModel.editBook(
                        book: book,
                        title: book.title,
                        author: book.author,
                        year: book.year,
                        genre: book.genre,
                        description: book.description
                    )
                    dismiss()
                }) {
                    Text("Save")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                        .padding(.horizontal)
                }
            }
            .padding(.vertical)
        }
        .background(Color(UIColor.systemGroupedBackground))
        .navigationBarHidden(true)
    }
}


struct BookDetailView_Previews: PreviewProvider {
    static var previews: some View {
        BookDetailView(viewModel: LibraryViewModel(bookRepository: InMemoryRepository()), book: Book(id: UUID(), title: "Sample Book", author: "Author", year: "2020", description: "An adventure", genre: "Thriller", coverImageUrl: "" ))
    }
}
