import SwiftUI

struct StartView: View {
    @ObservedObject var viewModel: LibraryViewModel

    init(viewModel: LibraryViewModel = LibraryViewModel(bookRepository: RealmBookRepository())) {
        self.viewModel = viewModel
    }

    var body: some View {
        TabView {
            NavigationView {
                BookListView(viewModel: viewModel)
                    .navigationBarTitle("Library", displayMode: .inline)
            }
            .tabItem {
                Image(systemName: "book.fill")
                Text("List")
            }

            NavigationView {
                SettingsView()
            }
            .tabItem {
                Image(systemName: "gear")
                Text("Settings")
            }
        }
    }
}

struct StartView_Previews: PreviewProvider {
    static var previews: some View {
        StartView(viewModel: LibraryViewModel(bookRepository: InMemoryRepository()))
    }
}
