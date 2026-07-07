import AppKit

final class AppDelegate: NSObject, NSApplicationDelegate {
    var appState: AppState!
    var menuBar: MenuBarController!

    func applicationDidFinishLaunching(_ notification: Notification) {
        appState = AppState()
        menuBar = MenuBarController(appState: appState)
        NotificationService.requestAuthIfNeeded()
    }

    func applicationWillTerminate(_ notification: Notification) {
        // 終了時に精算して保存
        appState.tickNow()
    }
}
