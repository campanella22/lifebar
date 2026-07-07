import Foundation

/// 人生の計算エンジン。全メソッドが純粋関数（副作用なし・時刻は引数で受ける）
public enum LifeEngine {
    /// ヒステリシス付きレベル判定。昇格は閾値到達で即時、転落は閾値×0.9未満で発生
    public static func level(forXP xp: Double, currentLevel: Int) -> Int {
        var lvl = currentLevel
        while lvl < Balance.maxLevel && xp >= Balance.levelThresholds[lvl + 1] { lvl += 1 }
        while lvl > 0 && xp < Balance.levelThresholds[lvl] * Balance.levelDownFactor { lvl -= 1 }
        return lvl
    }

    /// 現レベル内の進捗率（ゲージ表示用、0...1）
    public static func progress(xp: Double, level: Int) -> Double {
        guard level < Balance.maxLevel else { return 1 }
        let lo = Balance.levelThresholds[level]
        let hi = Balance.levelThresholds[level + 1]
        return min(1, max(0, (xp - lo) / (hi - lo)))
    }
}
