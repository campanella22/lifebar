import Foundation
import UserNotifications
import LifeBarCore

/// macOS 通知。バンドルなし（swift run）では UNUserNotificationCenter が使えないためスキップ
enum NotificationService {
    private static var available: Bool { Bundle.main.bundleIdentifier != nil }
    private static let presenter = BannerPresenter()

    static func requestAuthIfNeeded() {
        guard available else { return }
        let center = UNUserNotificationCenter.current()
        // アプリがアクティブ（ポップオーバー表示中など）でもバナーを出す
        center.delegate = presenter
        center.requestAuthorization(options: [.alert, .sound]) { _, _ in }
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

/// フォアグラウンドでも通知バナーを表示させるデリゲート
private final class BannerPresenter: NSObject, UNUserNotificationCenterDelegate {
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound])
    }
}
