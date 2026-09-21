import SwiftUI

@main
struct PrumoApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        MenuBarExtra {
            PopoverRoot(
                store: appDelegate.store,
                onStartPull: { appDelegate.drag.begin() },
                onQuit: { NSApp.terminate(nil) }
            )
        } label: {
            MenuBarLabel(store: appDelegate.store)
        }
        .menuBarExtraStyle(.window)
    }
}

struct MenuBarLabel: View {
    @ObservedObject var store: PrumoStore

    var body: some View {
        HStack(spacing: 4) {
            Image(nsImage: PlumbIcon.image(size: 16))
                .renderingMode(.template)
            if store.settings.showCountdown, let next = store.nextRunning {
                let left = max(0, next.endsAt - Int(Date().timeIntervalSince1970 * 1000))
                Text(Format.remaining(left, showSeconds: store.settings.showSeconds))
                    .monospacedDigit()
            } else {
                Text("Prumo")
            }
        }
    }
}
