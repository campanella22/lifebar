import XCTest
@testable import LifeBarCore

final class LifeStateTests: XCTestCase {
    let t0 = Date(timeIntervalSince1970: 1_750_000_000)

    func test_newGameは全パラメータゼロで始まる() {
        let s = LifeState.newGame(now: t0)
        for p in Param.allCases {
            XCTAssertEqual(s.params[p], ParamState(xp: 0, level: 0))
        }
        XCTAssertEqual(s.run, 1)
        XCTAssertNil(s.session)
        XCTAssertEqual(s.lastTickAt, t0)
    }

    func test_rebirthはパラメータをリセットし記録は残す() {
        var s = LifeState.newGame(now: t0)
        s.params[.muscle] = ParamState(xp: 3000, level: 4)
        s.totalStudyMinutes = 500
        s.hallOfFame.append(HallEntry(run: 1, achievedAt: t0, totalStudyMinutes: 500))
        s.warnedParams.insert(.money)
        let r = s.rebirth(now: t0.addingTimeInterval(60))
        XCTAssertEqual(r.params[.muscle], ParamState(xp: 0, level: 0))
        XCTAssertEqual(r.run, 2)
        XCTAssertEqual(r.hallOfFame.count, 1)          // 殿堂は残る
        XCTAssertEqual(r.totalStudyMinutes, 500)        // 生涯累計は残る
        XCTAssertTrue(r.warnedParams.isEmpty)
        XCTAssertNil(r.session)
    }

    func test_JSONラウンドトリップ() throws {
        var s = LifeState.newGame(now: t0)
        s.session = Session(target: .love, startedAt: t0)
        s.eventLog.append(LifeEvent(id: UUID(), date: t0, kind: .levelUp(param: .love, to: 1)))
        let enc = JSONEncoder(); enc.dateEncodingStrategy = .iso8601
        let dec = JSONDecoder(); dec.dateDecodingStrategy = .iso8601
        let restored = try dec.decode(LifeState.self, from: enc.encode(s))
        XCTAssertEqual(restored, s)
    }
}
