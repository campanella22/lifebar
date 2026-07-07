import Foundation
import UserNotifications
import LifeBarCore

/// macOS 通知。バンドルなし（swift run）では UNUserNotificationCenter が使えないためスキップ
enum NotificationService {
    private static var available: Bool { Bundle.main.bundleIdentifier != nil }
    private static let presenter = BannerPresenter()

    static func requestAuthIfNeeded() {
        guard available else {
            NSLog("LifeBar通知: バンドルIDなし（swift run 実行）のためスキップ")
            return
        }
        let center = UNUserNotificationCenter.current()
        // アプリがアクティブ（ポップオーバー表示中など）でもバナーを出す
        center.delegate = presenter
        center.requestAuthorization(options: [.alert, .sound]) { granted, error in
            center.getNotificationSettings { settings in
                // 0=未決定 1=拒否 2=許可 3=仮許可
                NSLog("LifeBar通知: granted=\(granted) status=\(settings.authorizationStatus.rawValue) error=\(error.map(String.init(describing:)) ?? "なし")")
            }
        }
        // -testNotification YES で起動2秒後にテスト通知（デバッグ用）
        if UserDefaults.standard.bool(forKey: "testNotification") {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                post([LifeEvent(date: Date(), kind: .levelUp(param: .love, to: 1))])
                NSLog("LifeBar通知: テスト通知を送信")
            }
        }
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
