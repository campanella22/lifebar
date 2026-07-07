import Foundation

public enum Param: String, Codable, CaseIterable, Sendable {
    case muscle, money, love
}

public struct ParamState: Codable, Equatable, Sendable {
    public var xp: Double
    public var level: Int
    public init(xp: Double = 0, level: Int = 0) {
        self.xp = xp
        self.level = level
    }
}

public struct Session: Codable, Equatable, Sendable {
    public var target: Param
    public var startedAt: Date
    public init(target: Param, startedAt: Date) {
        self.target = target
        self.startedAt = startedAt
    }
}

public struct HallEntry: Codable, Equatable, Sendable {
    public var run: Int
    public var achievedAt: Date
    public var totalStudyMinutes: Double
    public init(run: Int, achievedAt: Date, totalStudyMinutes: Double) {
        self.run = run
        self.achievedAt = achievedAt
        self.totalStudyMinutes = totalStudyMinutes
    }
}

public struct LifeEvent: Codable, Equatable, Identifiable, Sendable {
    public enum Kind: Codable, Equatable, Sendable {
        case levelUp(param: Param, to: Int)
        case levelDown(param: Param, from: Int, to: Int)
        case warning(param: Param)
        case victory(run: Int)
        case rockBottom(run: Int)
    }
    public let id: UUID
    public let date: Date
    public let kind: Kind
    public init(id: UUID = UUID(), date: Date, kind: Kind) {
        self.id = id
        self.date = date
        self.kind = kind
    }
}

public struct UserSettings: Codable, Equatable, Sendable {
    public var showElapsed: Bool
    public var launchAtLogin: Bool
    public init(showElapsed: Bool = true, launchAtLogin: Bool = false) {
        self.showElapsed = showElapsed
        self.launchAtLogin = launchAtLogin
    }
}

public struct LifeState: Codable, Equatable, Sendable {
    public var version: Int
    public var params: [Param: ParamState]
    public var lastTickAt: Date
    public var session: Session?
    public var run: Int
    /// 全XP0になった時刻（どん底カウント用）。どれかが0超になったら nil に戻す
    public var rockBottomSince: Date?
    /// 警告済みパラメータ（1回だけ通知するため）
    public var warnedParams: Set<Param>
    public var totalStudyMinutes: Double
    public var todayStudyMinutes: Double
    /// "yyyy-MM-dd"（ローカル時間）。日付が変わったら todayStudyMinutes をリセット
    public var todayKey: String
    public var hallOfFame: [HallEntry]
    public var eventLog: [LifeEvent]
    public var settings: UserSettings

    public static func newGame(now: Date) -> LifeState {
        LifeState(
            version: 1,
            params: Dictionary(uniqueKeysWithValues: Param.allCases.map { ($0, ParamState()) }),
            lastTickAt: now,
            session: nil,
            run: 1,
            rockBottomSince: nil,
            warnedParams: [],
            totalStudyMinutes: 0,
            todayStudyMinutes: 0,
            todayKey: LifeState.dayKey(now),
            hallOfFame: [],
            eventLog: [],
            settings: UserSettings()
        )
    }

    /// 新しい人生へ。記録（殿堂・ログ・設定・生涯累計）は引き継ぐ
    public func rebirth(now: Date) -> LifeState {
        var s = LifeState.newGame(now: now)
        s.run = run + 1
        s.totalStudyMinutes = totalStudyMinutes
        s.todayStudyMinutes = todayStudyMinutes
        s.todayKey = todayKey
        s.hallOfFame = hallOfFame
        s.eventLog = eventLog
        s.settings = settings
        return s
    }

    public static func dayKey(_ date: Date) -> String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        f.dateFormat = "yyyy-MM-dd"
        return f.string(from: date)
    }
}
