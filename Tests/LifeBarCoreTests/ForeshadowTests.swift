import XCTest
@testable import LifeBarCore

final class ForeshadowTests: XCTestCase {
    func test_次のレベルが近いと意味深メッセージが出る() {
        // 愛 Lv0・xp90 → 進捗 90/120 = 75% ≥ 70%
        XCTAssertEqual(Foreshadow.message(param: .love, level: 0, xp: 90),
                       "なんだか、青春の風が吹いている……")
    }

    func test_遠いときは何も言わない() {
        XCTAssertNil(Foreshadow.message(param: .love, level: 0, xp: 50))
    }

    func test_最大レベルでは何も言わない() {
        XCTAssertNil(Foreshadow.message(param: .muscle, level: 4, xp: 3000))
    }

    func test_全パラメータ全レベルに文言がある() {
        for p in Param.allCases {
            for lv in 0...3 {
                let almostNext = Balance.levelThresholds[lv + 1] - 1
                XCTAssertNotNil(Foreshadow.message(param: p, level: lv, xp: almostNext),
                                "\(p) Lv\(lv) の予感文言がない")
            }
        }
    }
}
