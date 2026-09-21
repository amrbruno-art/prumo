import AppKit
import UserNotifications

@main
final class AppDelegate: NSObject, NSApplicationDelegate {
    static private(set) var shared: AppDelegate!

    let store = PrumoStore()
    let notifier = Notifier()
    private var status: StatusItemController!
    private var drag: DragController!

    func applicationDidFinishLaunching(_ notification: Notification) {
        Self.shared = self
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

        status = StatusItemController(store: store)
        drag = DragController(store: store, status: status)
        status.drag = drag
        status.rebuild()
    }

    func applicationWillTerminate(_ notification: Notification) {
        store.save()
    }

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        false
    }
}
