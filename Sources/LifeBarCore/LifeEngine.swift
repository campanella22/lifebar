import Foundation

/// 人生の計算エンジン。全メソッドが純粋関数（副作用なし・時刻は引数で受ける）
public enum LifeEngine {
    /// ヒステリシス付きレベル判定。昇格は閾値到達で即時、転落は閾値×0.9未満で発生
    public static func level(forXP xp: Double, currentLevel: Int) -> Int {
        var lvl = currentLevel
        while lvl < Balance.maxLevel && xp >= Balance.levelThresholds[lvl + 1] { lvl += 1 }
        while lvl > 0 && xp < Balance.levelThresholds[lvl] * Balance.levelDownFactor { lvl -= 1 }
        return lvl
    }

    /// 現レベル内の進捗率（ゲージ表示用、0...1）
    public static func progress(xp: Double, level: Int) -> Double {
        guard level < Balance.maxLevel else { return 1 }
        let lo = Balance.levelThresholds[level]
        let hi = Balance.levelThresholds[level + 1]
        return min(1, max(0, (xp - lo) / (hi - lo)))
    }

    /// 時間経過の適用。起動時・1分ごと・セッション開始/終了時に呼ぶ。
    /// 数日分の放置も同じロジックで精算できる。
    public static func tick(_ state: LifeState, now: Date) -> (state: LifeState, events: [LifeEvent]) {
        var s = state
        var events: [LifeEvent] = []
        let dt = now.timeIntervalSince(s.lastTickAt)
        guard dt > 0 else { return (s, []) }
        s.lastTickAt = now

        // 日付ロールオーバー
        let key = LifeState.dayKey(now)
        if key != s.todayKey {
            s.todayKey = key
            s.todayStudyMinutes = 0
        }

        if let session = s.session {
            // 勉強中: 全パラメータ減衰停止、対象のみ加算
            let minutes = dt / 60
            s.params[session.target]!.xp += minutes * Balance.xpPerMinute
            s.totalStudyMinutes += minutes
            s.todayStudyMinutes += minutes
        } else {
            // 放置中: 全パラメータ減衰（下限0）
            let hours = dt / 3600
            for p in Param.allCases {
                s.params[p]!.xp = max(0, s.params[p]!.xp - hours * Balance.decayPerHour)
            }
        }

        // レベル再判定（変化はパラメータごとに1イベント）
        for p in Param.allCases {
            let old = s.params[p]!.level
            let new = level(forXP: s.params[p]!.xp, currentLevel: old)
            guard new != old else { continue }
            s.params[p]!.level = new
            let kind: LifeEvent.Kind = new > old
                ? .levelUp(param: p, to: new)
                : .levelDown(param: p, from: old, to: new)
            events.append(LifeEvent(date: now, kind: kind))
            s.warnedParams.remove(p)   // レベルが動いたら警告状態はリセット
        }

        s.eventLog.append(contentsOf: events)
        if s.eventLog.count > 200 {
            s.eventLog.removeFirst(s.eventLog.count - 200)
        }
        return (s, events)
    }

    /// セッション開始（直前までの減衰を精算してから開始）
    public static func startSession(_ state: LifeState, target: Param, now: Date) -> (state: LifeState, events: [LifeEvent]) {
        var (s, events) = tick(state, now: now)
        guard s.session == nil else { return (s, events) }
        s.session = Session(target: target, startedAt: now)
        return (s, events)
    }

    /// セッション終了（勉強分を精算）
    public static func stopSession(_ state: LifeState, now: Date) -> (state: LifeState, events: [LifeEvent]) {
        var (s, events) = tick(state, now: now)
        s.session = nil
        return (s, events)
    }
}
