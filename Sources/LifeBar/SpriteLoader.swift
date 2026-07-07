import AppKit

enum SpriteLoader {
    private static var cache: [String: NSImage] = [:]

    /// sprites/<name>.png を読み込む（メニューバー用は 18pt 表示に size をセット）
    static func image(_ name: String) -> NSImage? {
        if let hit = cache[name] { return hit }
        guard let url = Bundle.module.url(forResource: name, withExtension: "png", subdirectory: "sprites"),
              let img = NSImage(contentsOf: url) else { return nil }
        if name.hasPrefix("mb_") {
            img.size = NSSize(width: 18, height: 18)   // @2x として扱う
        }
        cache[name] = img
        return img
    }
}
