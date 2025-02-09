import SwiftUI

struct StartView: View {
    @ObservedObject var viewModel: LibraryViewModel
    @State private var selectedTab: Tab = .library
    @State private var customization = TabViewCustomization()

    init(viewModel: LibraryViewModel = LibraryViewModel(bookRepository: RealmBookRepository())) {
        self.viewModel = viewModel
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                ZStack {
                    if selectedTab == .library {
                        BookListView(viewModel: viewModel)
                    } else if selectedTab == .settings {
                        SettingsView()
                    }
                }

                HStack {
                    Spacer()
                    TabBarButton(icon: "book.fill", title: "Library", isSelected: selectedTab == .library) {
                        selectedTab = .library
                    }
                    Spacer()
                    TabBarButton(icon: "gearshape.fill", title: "Settings", isSelected: selectedTab == .settings) {
                        selectedTab = .settings
                    }
                    Spacer()
                }
                .padding(.vertical, 8)
                .background(
                    LinearGradient(gradient: Gradient(colors: [Color.blue, Color.purple]), startPoint: .leading, endPoint: .trailing)
                )
                .frame(maxWidth: .infinity)
                .frame(height: 25)
                .ignoresSafeArea(edges: .bottom)
                .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: -5)
            }
            .background(Color(.systemGroupedBackground).edgesIgnoringSafeArea(.all))
            .navigationBarHidden(true)
        }
    }
}

enum Tab {
    case library, settings
}

struct TabBarButton: View {
    var icon: String
    var title: String
    var isSelected: Bool
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack {
                Image(systemName: icon)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(isSelected ? Color.white : Color.white.opacity(0.7))
                Text(title)
                    .font(.caption2)
                    .foregroundColor(isSelected ? Color.white : Color.white.opacity(0.7))
            }
            .padding(.vertical, 4)
        }
    }
}

struct StartView_Previews: PreviewProvider {
    static var previews: some View {
        StartView(viewModel: LibraryViewModel(bookRepository: InMemoryRepository()))
    }
}
