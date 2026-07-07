import XCTest
@testable import LifeBarCore

final class StoreTests: XCTestCase {
    var dir: URL!

    override func setUp() {
        dir = FileManager.default.temporaryDirectory
            .appendingPathComponent("LifeBarTests-\(UUID().uuidString)")
    }

    override func tearDown() {
        try? FileManager.default.removeItem(at: dir)
    }

    func test_保存して読み込める() {
        let store = Store(directory: dir)
        var s = LifeState.newGame(now: Date(timeIntervalSince1970: 1_750_000_000))
        s.params[.muscle] = ParamState(xp: 500, level: 1)
        store.save(s)
        XCTAssertEqual(store.load(), s)
    }

    func test_ファイルが無ければnil() {
        XCTAssertNil(Store(directory: dir).load())
    }

    func test_壊れたJSONはnil() throws {
        let store = Store(directory: dir)
        store.save(LifeState.newGame(now: Date(timeIntervalSince1970: 1_750_000_000)))
        try "{broken".data(using: .utf8)!.write(to: dir.appendingPathComponent("state.json"))
        XCTAssertNil(store.load())
    }
}
