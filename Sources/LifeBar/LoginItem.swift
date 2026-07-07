import Foundation
import ServiceManagement

/// ログイン時起動。バンドル化されている時のみ有効（Task 15 の .app で動く）
enum LoginItem {
    static func apply(enabled: Bool) {
        guard Bundle.main.bundleIdentifier != nil else { return }
        do {
            if enabled {
                try SMAppService.mainApp.register()
            } else {
                try SMAppService.mainApp.unregister()
            }
        } catch {
            NSLog("ログイン項目の変更に失敗: \(error.localizedDescription)")
        }
    }
}
