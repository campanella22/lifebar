import Foundation

/// Application Support の JSON 1ファイルに全状態を保存する
public struct Store {
    let fileURL: URL

    public init(directory: URL) {
        try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        fileURL = directory.appendingPathComponent("state.json")
    }

    public static func defaultDirectory() -> URL {
        FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("LifeBar")
    }

    public func load() -> LifeState? {
        guard let data = try? Data(contentsOf: fileURL) else { return nil }
        let dec = JSONDecoder()
        dec.dateDecodingStrategy = .iso8601
        return try? dec.decode(LifeState.self, from: data)
    }

    public func save(_ state: LifeState) {
        let enc = JSONEncoder()
        enc.dateEncodingStrategy = .iso8601
        enc.outputFormatting = [.prettyPrinted, .sortedKeys]
        guard let data = try? enc.encode(state) else { return }
        try? data.write(to: fileURL, options: .atomic)
    }
}
