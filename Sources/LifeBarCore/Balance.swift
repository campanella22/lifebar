import Foundation

/// バランス数値の一元管理。ゲームの数値調整はこのファイルだけを触る。
public enum Balance {
    /// 勉強1分あたりの獲得XP
    public static let xpPerMinute: Double = 1
    /// 非勉強時の減衰（各パラメータ、1時間あたり）
    public static let decayPerHour: Double = 1
    /// Lv0〜Lv4 の必要累計XP
    public static let levelThresholds: [Double] = [0, 120, 600, 1500, 3000]
    public static let maxLevel = 4
    /// 転落は「現レベル閾値×この係数」を下回った時（バタつき防止）
    public static let levelDownFactor: Double = 0.9
    /// 転落この時間前に1回だけ警告
    public static let warningLeadTime: TimeInterval = 24 * 3600
    /// 全パラメータXP0がこの時間続くとどん底エンディング
    public static let rockBottomDuration: TimeInterval = 72 * 3600
}
