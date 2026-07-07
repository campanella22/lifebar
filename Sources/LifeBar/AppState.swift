import AppKit
import Combine
import LifeBarCore

/// Core と UI の橋渡し。tick の駆動・保存・イベントキュー管理を担う
@MainActor
final class AppState: ObservableObject {
    @Published private(set) var state: LifeState
    /// 未表示のイベントカード（先頭から表示）
    @Published private(set) var eventQueue: [LifeEvent] = []

    private let store: Store
    private let clock: AppClock
    private var timer: Timer?

    init() {
        clock = AppClock()
        let isDebug = clock.timeScale != 1
            || UserDefaults.standard.string(forKey: "demoState") != nil
        // デバッグ実行では本番セーブを汚さない
        let dir = isDebug
            ? FileManager.default.temporaryDirectory.appendingPathComponent("LifeBarDebug")
            : Store.defaultDirectory()
        store = Store(directory: dir)

        var s = store.load() ?? LifeState.newGame(now: clock.now())
        // 前回異常終了でセッションが残っていたら破棄（XPは前回tick分まで精算済み）
        s.session = nil
        if let demo = UserDefaults.standard.string(forKey: "demoState") {
            DemoPresets.apply(name: demo, to: &s)
        }
        state = s

        // エンジンtick: 通常60秒ごと。早回し時は追従のため1秒ごと
        let interval: TimeInterval = clock.timeScale > 1 ? 1 : 60
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            Task { @MainActor in self?.tickNow() }
        }
        tickNow()
    }

    func tickNow() {
        let (new, events) = LifeEngine.tick(state, now: clock.now())
        state = new
        if !events.isEmpty {
            eventQueue.append(contentsOf: events)
            NotificationService.post(events)
        }
        store.save(state)
    }

    func start(_ target: Param) {
        let (new, events) = LifeEngine.startSession(state, target: target, now: clock.now())
        state = new
        eventQueue.append(contentsOf: events)
        store.save(state)
    }

    func stop() {
        let (new, events) = LifeEngine.stopSession(state, now: clock.now())
        state = new
        eventQueue.append(contentsOf: events)
        if !events.isEmpty { NotificationService.post(events) }
        store.save(state)
    }

    func dismissEvent() {
        if !eventQueue.isEmpty { eventQueue.removeFirst() }
    }

    func updateSettings(_ settings: Settings) {
        state.settings = settings
        store.save(state)
    }

    func resetLife() {
        state = LifeState.newGame(now: clock.now())
        eventQueue = []
        store.save(state)
    }

    var isStudying: Bool { state.session != nil }

    func level(_ p: Param) -> Int { state.params[p]!.level }

    var title: String {
        TitleRule.title(muscle: level(.muscle), money: level(.money), love: level(.love))
    }

    /// セッション経過時間 "42:15" 形式（非稼働時 nil）
    var elapsedText: String? {
        guard let session = state.session else { return nil }
        let sec = Int(clock.now().timeIntervalSince(session.startedAt))
        return String(format: "%d:%02d", sec / 60, sec % 60)
    }
}
