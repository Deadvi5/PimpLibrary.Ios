#if canImport(UIKit)
import SwiftUI

extension View {
    /// Hides the keyboard by resigning the first responder.
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                        to: nil, from: nil, for: nil)
    }
    
    /// Adds a toolbar with a "Done" button to the keyboard.
    func addDoneButton() -> some View {
        self.toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") {
                    hideKeyboard()
                }
            }
        }
    }
}
#endif
