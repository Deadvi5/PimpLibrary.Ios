import SwiftUI
import UniformTypeIdentifiers

struct SettingsView: View {
    @ObservedObject var viewModel = SettingsViewModel()
    @State private var showingAlert = false
    @State private var showingExportSheet = false
    @State private var showingImportPicker = false
    @State private var showingSuccessMessage = false
    @AppStorage("groupBy") private var groupBy: String = "None"
    @AppStorage("selectedAPI") private var selectedAPI: String = "Open Library"
    // New setting for estimated pages per day; default is 20
    @AppStorage("pagesPerDay") private var pagesPerDay: Int = 20
    
    var body: some View {
        Form {
            Section(header: Text("API Selection").font(.headline)) {
                Picker("Select API", selection: $selectedAPI) {
                    Text("Open Library").tag("Open Library")
                    Text("Google Books").tag("Google Books")
                }
                .pickerStyle(SegmentedPickerStyle())
            }
            
            Section(header: Text("Reading Settings").font(.headline)) {
                HStack {
                    Text("Pages per Day")
                    Spacer()
                    TextField("", value: $pagesPerDay, formatter: NumberFormatter())
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 60)
                        .addDoneButton() // Add toolbar with Done button to dismiss keyboard
                }
            }
            
            Section(header: Text("Delete Data").font(.headline)) {
                Button(action: {
                    showingAlert = true
                }) {
                    Text("Delete All Books")
                        .foregroundColor(.red)
                }
                .alert(isPresented: $showingAlert) {
                    Alert(
                        title: Text("Delete All Books"),
                        message: Text("Are you sure you want to delete all your books? This action cannot be undone."),
                        primaryButton: .destructive(Text("Delete")) {
                            viewModel.deleteRealmFile()
                        },
                        secondaryButton: .cancel()
                    )
                }
            }
            
            Section(header: Text("Import and Export Data").font(.headline)) {
                Button(action: {
                    viewModel.exportBooks()
                    showingExportSheet = true
                }) {
                    Text("Export Books")
                }
                .fileExporter(
                    isPresented: $showingExportSheet,
                    document: viewModel.exportedFile,
                    contentType: .pimplib,
                    defaultFilename: "BooksBackup"
                ) { result in
                    switch result {
                    case .success(let url):
                        print("Exported to \(url)")
                    case .failure(let error):
                        print("Export failed: \(error.localizedDescription)")
                    }
                }
                
                Button(action: {
                    showingImportPicker = true
                }) {
                    Text("Import Books")
                }
                .fileImporter(
                    isPresented: $showingImportPicker,
                    allowedContentTypes: [.pimplib],
                    allowsMultipleSelection: false
                ) { result in
                    switch result {
                    case .success(let urls):
                        if let url = urls.first {
                            viewModel.importBooks(from: url) { success in
                                if success { showingSuccessMessage = true }
                            }
                        }
                    case .failure(let error):
                        print("Failed to import file: \(error.localizedDescription)")
                    }
                }
                .alert(isPresented: $showingSuccessMessage) {
                    Alert(
                        title: Text("Success"),
                        message: Text("Books were successfully imported."),
                        dismissButton: .default(Text("OK"))
                    )
                }
            }
            
            Section(header: Text("View Options").font(.headline)) {
                Toggle(isOn: $viewModel.useGridView) {
                    Text("Use Grid View")
                }
                .onChange(of: viewModel.useGridView) { _, _ in
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
        }
        .navigationBarTitle("Settings", displayMode: .inline)
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
