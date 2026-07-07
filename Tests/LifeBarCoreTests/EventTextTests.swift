import XCTest
@testable import LifeBarCore

final class EventTextTests: XCTestCase {
    func test_全イベント種別に文言がある() {
        for p in Param.allCases {
            for lv in 1...4 {
                XCTAssertFalse(EventText.text(for: .levelUp(param: p, to: lv)).isEmpty)
                XCTAssertFalse(EventText.text(for: .levelDown(param: p, from: lv, to: lv - 1)).isEmpty)
            }
            XCTAssertFalse(EventText.text(for: .warning(param: p)).isEmpty)
        }
        XCTAssertFalse(EventText.text(for: .victory(run: 1)).isEmpty)
        XCTAssertFalse(EventText.text(for: .rockBottom(run: 1)).isEmpty)
    }

    func test_代表文言() {
        XCTAssertEqual(EventText.text(for: .levelUp(param: .love, to: 1)), "彼女ができた！")
        XCTAssertEqual(EventText.text(for: .levelDown(param: .love, from: 2, to: 1)), "妻が家を出て行った……")
        XCTAssertEqual(EventText.text(for: .levelDown(param: .money, from: 2, to: 1)), "会社が倒産した……")
    }
}
