import SwiftUI

struct ContentView: View {
    @State private var books: [Book] = []

    var body: some View {
        NavigationView {
            List(books, id: \.id) { book in
                NavigationLink(destination: BookDetailView(book: book)) {
                    HStack {
                        if let coverImageUrl = book.coverImageUrl, let url = URL(string: coverImageUrl) {
                            AsyncImage(url: url)
                                .frame(width: 50, height: 75)
                                .aspectRatio(contentMode: .fit)
                        } else {
                            Rectangle()
                                .fill(Color.gray)
                                .frame(width: 50, height: 75)
                        }
                        VStack(alignment: .leading) {
                            Text(book.title)
                                .font(.headline)
                            Text(book.author)
                                .font(.subheadline)
                        }
                    }
                }
            }
            .navigationTitle("Books")
        }
        .onAppear {
            fetchBooks()
        }
    }

    private func fetchBooks() {
        NetworkManager.shared.fetchBooks(query: "swift programming") { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let books):
                    self.books = books
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
}

struct ContentBookDetailView: View {
    let book: Book

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if let coverImageUrl = book.coverImageUrl, let url = URL(string: coverImageUrl) {
                AsyncImage(url: url)
                    .frame(maxHeight: 300)
                    .aspectRatio(contentMode: .fit)
            } else {
                Rectangle()
                    .fill(Color.gray)
                    .frame(maxHeight: 300)
            }
            Text(book.title)
                .font(.largeTitle)
                .bold()
            Text("by \(book.author)")
                .font(.title2)
                .foregroundColor(.secondary)
            Text(book.description)
                .font(.body)
            Spacer()
        }
        .padding()
        .navigationTitle("Book Details")
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
