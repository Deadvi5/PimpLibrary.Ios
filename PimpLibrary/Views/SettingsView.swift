import SwiftUI
import UniformTypeIdentifiers

struct SettingsView: View {
    @ObservedObject var viewModel = SettingsViewModel()
    @State private var showingAlert = false
    @State private var showingExportSheet = false
    @State private var showingImportPicker = false
    @State private var showingSuccessMessage = false
    
    var body: some View {
        Form {
            Section(header: Text("Delete Data")) {
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
            
            Section(header: Text("Import and Export Data")) {
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
                                if success {
                                    showingSuccessMessage = true
                                }
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
            
            Section(header: Text("View Options")) {
                Toggle(isOn: $viewModel.useGridView) {
                    Text("Use Grid View")
                }
                .onChange(of: viewModel.useGridView ) { _,_ in
                    viewModel.toggleUseGridView()
                }
            }
        }
        .navigationBarTitle("Settings", displayMode: .inline)
    }
}
