import AppKit
import os
import UserNotifications

final class AppDelegate: NSObject, NSApplicationDelegate {
    static private(set) var shared: AppDelegate!

    let store: PrumoStore
    let notifier: Notifier
    let drag: DragController
    private let log = Logger(subsystem: "art.amrbruno.prumo", category: "launch")

    override init() {
        let store = PrumoStore()
        self.store = store
        self.notifier = Notifier()
        self.drag = DragController(store: store)
        super.init()
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        Self.shared = self
        ProcessInfo.processInfo.disableAutomaticTermination("Prumo menu extra")
        ProcessInfo.processInfo.disableSuddenTermination()
        NSApp.setActivationPolicy(.accessory)

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
        log.info("Prumo extra should be on the right of the menu bar. No Dock icon.")
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        false
    }

    func applicationWillTerminate(_ notification: Notification) {
        store.save()
    }

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        false
    }
}
