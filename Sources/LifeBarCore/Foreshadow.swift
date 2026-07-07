/// 次のレベルが近づいた時の「予感」メッセージ。
/// セッション終了サマリーで、何かが起きそうな気配だけを匂わせる。
public enum Foreshadow {
    // インデックスは現在レベル（= 次のレベル - 1）
    static let texts: [Param: [String]] = [
        .muscle: [
            "シャツが少しきつくなってきた気がする……",
            "鏡の前に立つ時間が増えた……",
            "ジムで誰かの視線を感じる……",
            "もはや歩くだけで風が起こる……",
        ],
        .money: [
            "風で求人誌が足元に飛んできた……",
            "スーツ姿の自分を想像してしまう……",
            "頭の中にビジネスのアイデアが降りてきた……",
            "不動産のチラシから目が離せない……",
        ],
        .love: [
            "なんだか、青春の風が吹いている……",
            "彼女がやたらと指輪の話をしてくる……",
            "妻がそっとお腹に手を当てていた……",
            "子供が誰かを家に連れてきたいらしい……",
        ],
    ]

    /// 進捗が閾値（Balance.foreshadowProgress）以上なら意味深な一言を返す。遠ければ nil
    public static func message(param: Param, level: Int, xp: Double) -> String? {
        guard level < Balance.maxLevel else { return nil }
        guard LifeEngine.progress(xp: xp, level: level) >= Balance.foreshadowProgress else { return nil }
        return texts[param]![level]
    }
}
