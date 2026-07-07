import XCTest
@testable import LifeBarCore

final class TitleRuleTests: XCTestCase {
    func test_代表的な称号() {
        XCTAssertEqual(TitleRule.title(muscle: 4, money: 4, love: 4), "人生の勝者")
        XCTAssertEqual(TitleRule.title(muscle: 3, money: 0, love: 0), "ムキムキ無職・独身")
        XCTAssertEqual(TitleRule.title(muscle: 3, money: 0, love: 2), "ムキムキ無職")
        XCTAssertEqual(TitleRule.title(muscle: 0, money: 3, love: 1), "痩せた社長")
        XCTAssertEqual(TitleRule.title(muscle: 0, money: 0, love: 2), "愛だけはある男")
        XCTAssertEqual(TitleRule.title(muscle: 0, money: 0, love: 0), "ただの男")
    }

    func test_どの組み合わせでも必ず称号が返る() {
        for m in 0...4 { for k in 0...4 { for l in 0...4 {
            XCTAssertFalse(TitleRule.title(muscle: m, money: k, love: l).isEmpty)
        }}}
    }
}
