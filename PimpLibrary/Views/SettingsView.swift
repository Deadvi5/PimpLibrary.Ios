import SwiftUI
import UniformTypeIdentifiers

struct SettingsView: View {
    @ObservedObject var viewModel = SettingsViewModel()
    @State private var showingAlert = false
    @State private var showingExportSheet = false
    @State private var showingImportPicker = false
    @State private var showingSuccessMessage = false
    @AppStorage("groupBy") private var groupBy: String = "None"
    @AppStorage("selectedAPI") private var selectedAPI: String = "Google Books"
    @AppStorage("pagesPerDay") private var pagesPerDay: Int = 20

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                Text("Settings")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                settingsCard(title: "API Selection") {
                    Picker("Select API", selection: $selectedAPI) {
                        Text("Open Library").tag("Open Library")
                        Text("Google Books").tag("Google Books")
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                settingsCard(title: "View Options") {
                    Toggle("Use Grid View", isOn: $viewModel.useGridView)
                        .onChange(of: viewModel.useGridView) {
                            viewModel.toggleUseGridView()
                        }


                    VStack(alignment: .leading) {
                        Text("Group Books By")
                        Picker("Group Books By", selection: $groupBy) {
                            Text("None").tag("None")
                            Text("Genre").tag("Genre")
                            Text("Author").tag("Author")
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }
                }

                settingsCard(title: "Reading Settings") {
                    HStack {
                        Text("Pages per Day")
                        Spacer()
                        TextField("", value: $pagesPerDay, formatter: NumberFormatter())
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 60)
                            .addDoneButton()
                    }
                }

                settingsCard(title: "Import and Export Data") {
                    VStack(spacing: 15) {
                        Button(action: {
                            viewModel.exportBooks()
                            showingExportSheet = true
                        }) {
                            Text("Export Books")
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .cornerRadius(10)
                        }
                        .fileExporter(
                            isPresented: $showingExportSheet,
                            document: viewModel.exportedFile,
                            contentType: .pimplib,
                            defaultFilename: "BooksBackup"
                        ) { result in
                            if case .failure(let error) = result {
                                print("Export failed: \(error.localizedDescription)")
                            }
                        }

                        Button(action: { showingImportPicker = true }) {
                            Text("Import Books")
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.green)
                                .cornerRadius(10)
                        }
                        .fileImporter(
                            isPresented: $showingImportPicker,
                            allowedContentTypes: [.pimplib],
                            allowsMultipleSelection: false
                        ) { result in
                            if case .success(let urls) = result, let url = urls.first {
                                viewModel.importBooks(from: url) { success in
                                    if success { showingSuccessMessage = true }
                                }
                            }
                        }
                        .alert(isPresented: $showingSuccessMessage) {
                            Alert(title: Text("Success"), message: Text("Books were successfully imported."), dismissButton: .default(Text("OK")))
                        }
                    }
                }
                
                settingsCard(title: "Delete Data") {
                    Button(action: { showingAlert = true }) {
                        Text("Delete All Books")
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red)
                            .cornerRadius(10)
                    }
                    .alert(isPresented: $showingAlert) {
                        Alert(
                            title: Text("Delete All Books"),
                            message: Text("Are you sure you want to delete all your books? This action cannot be undone."),
                            primaryButton: .destructive(Text("Delete")) { viewModel.deleteRealmFile() },
                            secondaryButton: .cancel()
                        )
                    }
                }

                Spacer()
            }
            .padding()
            .background(Color(.systemGroupedBackground).edgesIgnoringSafeArea(.all))
        }
        .navigationBarHidden(true)
    }

    private func settingsCard<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.headline)
                .foregroundColor(.gray)
            content()
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
