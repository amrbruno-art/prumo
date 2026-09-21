import AppKit
import os
import UserNotifications

final class AppDelegate: NSObject, NSApplicationDelegate {
    static private(set) var shared: AppDelegate!

    let store = PrumoStore()
    let notifier = Notifier()
    private var status: StatusItemController!
    private var drag: DragController!
    private let log = Logger(subsystem: "art.amrbruno.prumo", category: "launch")

    func applicationDidFinishLaunching(_ notification: Notification) {
        Self.shared = self
        ProcessInfo.processInfo.disableAutomaticTermination("Prumo menu extra")
        ProcessInfo.processInfo.disableSuddenTermination()
        NSApp.setActivationPolicy(.accessory)

        // Status item first so the extra exists even if later setup fails.
        status = StatusItemController(store: store)
        drag = DragController(store: store, status: status)
        status.drag = drag

        UNUserNotificationCenter.current().delegate = notifier
        store.load()
        store.onFire = { [weak self] timer in
            guard let self else { return }
            self.notifier.announce(timer, language: self.store.settings.language)
            if self.store.settings.sound {
                SoundPlayer.chime()
            }
        }
        store.startTicking()
        status.rebuild()
        log.info("Prumo menu extra is in the menu bar (no Dock icon).")
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        false
    }

    func applicationWillTerminate(_ notification: Notification) {
        store.save()
    }

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        status?.rebuild()
        return false
    }
}
