import SwiftUI

struct SortingOptionsView: View {
    @Binding var sortCriteria: String
    @Binding var isAscending: Bool

    var body: some View {
        Form {
            Section(header: Text("Sort Criteria")) {
                Picker(selection: $sortCriteria, label: Text("Select Sort Criteria")) {
                    Text("Title").tag("Title")
                    Text("Author").tag("Author")
                    Text("Year").tag("Year")
                }
                .pickerStyle(SegmentedPickerStyle())
            }

            Section(header: Text("Order")) {
                Toggle(isOn: $isAscending) {
                    Text(isAscending ? "Ascending" : "Descending")
                }
            }
        }
        .navigationTitle("Sorting Options")
    }
}

struct SortingOptionsView_Previews: PreviewProvider {
    @State static var sortCriteria = "Title"
    @State static var isAscending = true

    static var previews: some View {
        NavigationView {
            SortingOptionsView(sortCriteria: $sortCriteria, isAscending: $isAscending)
        }
    }
}
