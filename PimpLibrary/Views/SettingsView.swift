import SwiftUI

struct SettingsView: View {
    @ObservedObject var viewModel = SettingsViewModel()
    @State private var showingAlert = false

    var body: some View {
            Form {
                Section(header: Text("Database Management").font(.headline)) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Delete Realm Database")
                            .font(.headline)
                        
                        Text("This action will permanently delete all data stored in the Realm database. Please make sure to backup your data if needed before proceeding.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Button(action: {
                            showingAlert = true
                        }) {
                            Text("Delete Database")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.red)
                                .cornerRadius(10)
                        }
                        .alert(isPresented: $showingAlert) {
                            Alert(
                                title: Text("Delete Realm Database"),
                                message: Text("Are you sure you want to delete the Realm database? This action cannot be undone."),
                                primaryButton: .destructive(Text("Delete")) {
                                    viewModel.deleteRealmFile()
                                },
                                secondaryButton: .cancel()
                            )
                        }
                    }
                    .padding(.vertical, 5)
                }
            }
        }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
