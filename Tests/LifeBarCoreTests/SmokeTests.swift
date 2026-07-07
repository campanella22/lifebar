import XCTest
@testable import LifeBarCore

final class SmokeTests: XCTestCase {
    func test_バージョンが取れる() {
        XCTAssertEqual(LifeBarCore.version, "0.1.0")
    }
}
