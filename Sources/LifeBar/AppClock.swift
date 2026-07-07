import Foundation

/// -timeScale 起動引数で時間を早回しできる時計（デバッグ用）
struct AppClock {
    let launchedAt = Date()
    let timeScale: Double

    init() {
        let v = UserDefaults.standard.double(forKey: "timeScale")
        timeScale = v > 0 ? v : 1
    }

    func now() -> Date {
        guard timeScale != 1 else { return Date() }
        return launchedAt.addingTimeInterval(Date().timeIntervalSince(launchedAt) * timeScale)
    }
}
