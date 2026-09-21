import Foundation
import UserNotifications

final class Notifier: NSObject, UNUserNotificationCenterDelegate {
    static func request() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in }
    }

    static func schedule(_ timer: PrumoTimer, language: Lang, enabled: Bool) {
        cancel(timer.id)
        guard enabled else { return }
        let content = UNMutableNotificationContent()
        content.title = timer.title.isEmpty ? "Prumo" : timer.title
        content.body = Copy.firedBody(language)
        content.sound = .default
        let remaining = max(1.0, Double(timer.endsAt) / 1000.0 - Date().timeIntervalSince1970)
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: remaining, repeats: false)
        let req = UNNotificationRequest(identifier: timer.id, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(req)
    }

    static func cancel(_ id: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id])
        UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: [id])
    }

    func announce(_ timer: PrumoTimer, language: Lang) {
        let content = UNMutableNotificationContent()
        content.title = timer.title.isEmpty ? "Prumo" : timer.title
        content.body = Copy.firedBody(language)
        content.sound = .default
        let req = UNNotificationRequest(
            identifier: timer.id + "-now",
            content: content,
            trigger: nil
        )
        UNUserNotificationCenter.current().add(req)
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        [.banner, .sound, .list]
    }
}
