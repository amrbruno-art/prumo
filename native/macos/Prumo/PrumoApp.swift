import SwiftUI

@main
struct PrumoApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        // Keeps the SwiftUI lifecycle without a document window.
        // The extra itself is an NSStatusItem (see AppDelegate).
        Settings {
            EmptyView()
        }
    }
}
