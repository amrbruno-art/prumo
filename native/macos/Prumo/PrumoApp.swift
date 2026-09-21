import SwiftUI

@main
struct PrumoApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        // Fully qualified: Models.Settings would otherwise shadow SwiftUI.Settings.
        SwiftUI.Settings {
            EmptyView()
        }
    }
}
