import XCTest
@testable import LifeBarCore

final class LifeEngineTests: XCTestCase {
    let t0 = Date(timeIntervalSince1970: 1_750_000_000)

    func 状態(muscle: Double = 0, money: Double = 0, love: Double = 0) -> LifeState {
        var s = LifeState.newGame(now: t0)
        s.params[.muscle] = ParamState(xp: muscle, level: LifeEngine.level(forXP: muscle, currentLevel: 0))
        s.params[.money] = ParamState(xp: money, level: LifeEngine.level(forXP: money, currentLevel: 0))
        s.params[.love] = ParamState(xp: love, level: LifeEngine.level(forXP: love, currentLevel: 0))
        return s
    }

    func test_非勉強時は1時間1XPずつ全パラメータ減衰() {
        let s = 状態(muscle: 100, money: 50, love: 10)
        let (r, _) = LifeEngine.tick(s, now: t0.addingTimeInterval(10 * 3600))  // 10時間後
        XCTAssertEqual(r.params[.muscle]!.xp, 90, accuracy: 0.001)
        XCTAssertEqual(r.params[.money]!.xp, 40, accuracy: 0.001)
        XCTAssertEqual(r.params[.love]!.xp, 0, accuracy: 0.001)   // 下限0
        XCTAssertEqual(r.lastTickAt, t0.addingTimeInterval(10 * 3600))
    }

    func test_勉強中は対象に加算され減衰は全停止() {
        var s = 状態(muscle: 100, money: 100, love: 100)
        (s, _) = LifeEngine.startSession(s, target: .muscle, now: t0)
        let (r, _) = LifeEngine.tick(s, now: t0.addingTimeInterval(60 * 60))    // 60分勉強
        XCTAssertEqual(r.params[.muscle]!.xp, 160, accuracy: 0.001)             // +60
        XCTAssertEqual(r.params[.money]!.xp, 100, accuracy: 0.001)              // 減衰なし
        XCTAssertEqual(r.totalStudyMinutes, 60, accuracy: 0.001)
        XCTAssertEqual(r.todayStudyMinutes, 60, accuracy: 0.001)
    }

    func test_昇格イベントが発火する() {
        var s = 状態(muscle: 119)
        (s, _) = LifeEngine.startSession(s, target: .muscle, now: t0)
        let (r, events) = LifeEngine.tick(s, now: t0.addingTimeInterval(120))   // 2分勉強 → 121XP
        XCTAssertEqual(r.params[.muscle]!.level, 1)
        XCTAssertEqual(events.count, 1)
        guard case .levelUp(param: .muscle, to: 1) = events[0].kind else {
            return XCTFail("levelUpイベントが出ていない: \(events)")
        }
        XCTAssertEqual(r.eventLog.count, 1)   // ログにも残る
    }

    func test_転落イベントは複数レベルでも1件にまとまる() {
        // Lv2(xp=600) から10日放置 → xp=360 → Lv1閾値120は上回るがLv2床540を割る → Lv1
        var s = 状態(muscle: 600)
        var (r, events) = LifeEngine.tick(s, now: t0.addingTimeInterval(10 * 24 * 3600))
        XCTAssertEqual(r.params[.muscle]!.xp, 360, accuracy: 0.001)
        XCTAssertEqual(r.params[.muscle]!.level, 1)
        let downs = events.filter { if case .levelDown = $0.kind { true } else { false } }
        XCTAssertEqual(downs.count, 1)
        guard case .levelDown(param: .muscle, from: 2, to: 1) = downs[0].kind else {
            return XCTFail("from2 to1 のはず: \(downs)")
        }
        // さらに一気に0まで: 追加15日
        s = r
        (r, events) = LifeEngine.tick(s, now: t0.addingTimeInterval(25 * 24 * 3600))
        guard case .levelDown(param: .muscle, from: 1, to: 0) = events.first(where: { if case .levelDown = $0.kind { true } else { false } })!.kind else {
            return XCTFail("from1 to0 のはず")
        }
    }

    func test_停止で精算されセッションが消える() {
        var s = 状態()
        (s, _) = LifeEngine.startSession(s, target: .love, now: t0)
        let (r, _) = LifeEngine.stopSession(s, now: t0.addingTimeInterval(30 * 60))
        XCTAssertNil(r.session)
        XCTAssertEqual(r.params[.love]!.xp, 30, accuracy: 0.001)
    }

    func test_日付が変わると今日の合計がリセットされる() {
        var s = 状態()
        (s, _) = LifeEngine.startSession(s, target: .money, now: t0)
        (s, _) = LifeEngine.stopSession(s, now: t0.addingTimeInterval(60 * 60))
        XCTAssertEqual(s.todayStudyMinutes, 60, accuracy: 0.001)
        let (r, _) = LifeEngine.tick(s, now: t0.addingTimeInterval(3 * 24 * 3600))  // 3日後
        XCTAssertEqual(r.todayStudyMinutes, 0, accuracy: 0.001)
        XCTAssertEqual(r.totalStudyMinutes, 60, accuracy: 0.001)   // 生涯累計は残る
    }

    func test_転落24時間前に警告が1回だけ出る() {
        // Lv1 床108。xp=130 なら残り22時間 → 警告ゾーン
        let s = 状態(muscle: 132)   // 2時間減衰後に130
        let (r1, e1) = LifeEngine.tick(s, now: t0.addingTimeInterval(2 * 3600))
        XCTAssertTrue(e1.contains { if case .warning(param: .muscle) = $0.kind { true } else { false } })
        // さらに1時間 → 2回目は出ない
        let (_, e2) = LifeEngine.tick(r1, now: t0.addingTimeInterval(3 * 3600))
        XCTAssertFalse(e2.contains { if case .warning = $0.kind { true } else { false } })
    }

    func test_勉強してゾーンを出れば警告状態が解除される() {
        let s = 状態(muscle: 132)
        var r: LifeState
        (r, _) = LifeEngine.tick(s, now: t0.addingTimeInterval(2 * 3600))       // xp130 → 警告発火済み
        XCTAssertEqual(r.warnedParams, [.muscle])
        (r, _) = LifeEngine.startSession(r, target: .muscle, now: t0.addingTimeInterval(2 * 3600))
        (r, _) = LifeEngine.stopSession(r, now: t0.addingTimeInterval(2 * 3600 + 100 * 60))  // +100XP → 230
        // 警告判定は放置中のみ行われるため、停止後の次のtickで解除される
        (r, _) = LifeEngine.tick(r, now: t0.addingTimeInterval(2 * 3600 + 101 * 60))
        XCTAssertTrue(r.warnedParams.isEmpty)   // ゾーン離脱（残り>24h）で解除
    }

    func test_全ゼロ72時間でどん底エンディング() {
        let s = 状態()   // 全部0
        let (r1, _) = LifeEngine.tick(s, now: t0.addingTimeInterval(3600))
        XCTAssertNotNil(r1.rockBottomSince)
        let (r2, e2) = LifeEngine.tick(r1, now: t0.addingTimeInterval(3600 + 72 * 3600))
        XCTAssertTrue(e2.contains { if case .rockBottom(run: 1) = $0.kind { true } else { false } })
        XCTAssertEqual(r2.run, 2)   // 転生済み
    }

    func test_全Lv4で勝利し殿堂入りして転生() {
        var s = 状態(muscle: 2999, money: 3000, love: 3000)
        s.totalStudyMinutes = 9000
        (s, _) = LifeEngine.startSession(s, target: .muscle, now: t0)
        let (r, events) = LifeEngine.tick(s, now: t0.addingTimeInterval(120))   // muscleが3000超え
        XCTAssertTrue(events.contains { if case .victory(run: 1) = $0.kind { true } else { false } })
        XCTAssertEqual(r.hallOfFame.count, 1)
        XCTAssertEqual(r.hallOfFame[0].run, 1)
        XCTAssertEqual(r.run, 2)
        XCTAssertEqual(r.params[.muscle]!.xp, 0, accuracy: 0.001)   // 新しい人生
    }

    func test_過去や同時刻のtickは無変化() {
        let s = 状態(muscle: 100)
        let (r, events) = LifeEngine.tick(s, now: t0)
        XCTAssertEqual(r, s)
        XCTAssertTrue(events.isEmpty)
    }

    func test_昇格は閾値到達で即時() {
        XCTAssertEqual(LifeEngine.level(forXP: 119, currentLevel: 0), 0)
        XCTAssertEqual(LifeEngine.level(forXP: 120, currentLevel: 0), 1)
        XCTAssertEqual(LifeEngine.level(forXP: 3000, currentLevel: 0), 4)  // 複数レベル一気に
    }

    func test_転落は閾値の9割を下回ってから() {
        // Lv2 の閾値600 → 540未満で転落
        XCTAssertEqual(LifeEngine.level(forXP: 545, currentLevel: 2), 2)   // まだ耐える
        XCTAssertEqual(LifeEngine.level(forXP: 539, currentLevel: 2), 1)   // 転落
        // Lv1 の閾値120 → 108未満で転落
        XCTAssertEqual(LifeEngine.level(forXP: 108, currentLevel: 1), 1)
        XCTAssertEqual(LifeEngine.level(forXP: 107, currentLevel: 1), 0)
    }

    func test_進捗率はレベル内の割合() {
        XCTAssertEqual(LifeEngine.progress(xp: 0, level: 0), 0, accuracy: 0.001)
        XCTAssertEqual(LifeEngine.progress(xp: 60, level: 0), 0.5, accuracy: 0.001)   // 0→120 の半分
        XCTAssertEqual(LifeEngine.progress(xp: 360, level: 1), 0.5, accuracy: 0.001)  // 120→600 の半分
        XCTAssertEqual(LifeEngine.progress(xp: 3000, level: 4), 1, accuracy: 0.001)   // MAXは常に満タン
        XCTAssertEqual(LifeEngine.progress(xp: 100, level: 1), 0, accuracy: 0.001)    // 閾値割れ中は0で下限
    }
}
