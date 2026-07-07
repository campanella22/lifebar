import XCTest
@testable import LifeBarCore

final class LifeEngineTests: XCTestCase {
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
