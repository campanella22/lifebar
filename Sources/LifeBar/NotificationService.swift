import Foundation
import UserNotifications
import LifeBarCore

/// macOS 通知。バンドルなし（swift run）では UNUserNotificationCenter が使えないためスキップ
enum NotificationService {
    private static var available: Bool { Bundle.main.bundleIdentifier != nil }

    static func requestAuthIfNeeded() {
        guard available else { return }
        UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .sound]) { _, _ in }
    }

    static func post(_ events: [LifeEvent]) {
        guard available else { return }
        let center = UNUserNotificationCenter.current()
        for event in events {
            let content = UNMutableNotificationContent()
            content.title = "LifeBar"
            content.body = EventText.text(for: event.kind)
            center.add(UNNotificationRequest(
                identifier: event.id.uuidString, content: content, trigger: nil))
        }
    }
}
