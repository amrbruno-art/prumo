import AppKit
import os
import UserNotifications

final class AppDelegate: NSObject, NSApplicationDelegate {
    static private(set) var shared: AppDelegate!

    let store: PrumoStore
    let notifier: Notifier
    private var status: StatusItemController!
    private(set) var drag: DragController!
    private let log = Logger(subsystem: "art.amrbruno.prumo", category: "launch")

    override init() {
        let store = PrumoStore()
        self.store = store
        self.notifier = Notifier()
        super.init()
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        Self.shared = self
        ProcessInfo.processInfo.disableAutomaticTermination("Prumo menu extra")
        ProcessInfo.processInfo.disableSuddenTermination()
        writeBreadcrumb()

        // Status item FIRST, while the app is still a regular app, so the
        // extra actually attaches. Hide the Dock afterwards.
        status = StatusItemController(store: store)
        drag = DragController(store: store, status: status)
        status.drag = drag
        status.rebuild()

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

        DispatchQueue.main.async {
            NSApp.setActivationPolicy(.accessory)
            self.status.rebuild()
            self.log.info("Prumo extra installed. Not in Dock, not in Force Quit.")
        }
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

    private func writeBreadcrumb() {
        let dir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first?
            .appendingPathComponent("Prumo", isDirectory: true)
        guard let dir else { return }
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        let line = ISO8601DateFormatter().string(from: Date()) + " launched\n"
        try? line.write(to: dir.appendingPathComponent("last-launch.txt"), atomically: true, encoding: .utf8)
    }
}
