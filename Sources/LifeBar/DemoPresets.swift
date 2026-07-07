import Foundation
import LifeBarCore

/// -demoState 起動引数で代表状態を再現する（デバッグ用）
enum DemoPresets {
    static func apply(name: String, to state: inout LifeState) {
        func set(_ p: Param, xp: Double) {
            state.params[p] = ParamState(xp: xp, level: LifeEngine.level(forXP: xp, currentLevel: 0))
        }
        switch name {
        case "mukimuki":         // ムキムキ無職・独身（ボロ小屋＋ゴリマッチョ）
            set(.muscle, xp: 1600); set(.money, xp: 0); set(.love, xp: 0)
        case "family":           // 愛に生きる男（赤屋根の家＋妻子）
            set(.muscle, xp: 700); set(.money, xp: 700); set(.love, xp: 1600)
        case "shacho":           // 痩せた社長（ビル＋もやし＋彼女）
            set(.muscle, xp: 0); set(.money, xp: 1600); set(.love, xp: 130)
        case "ai_dake":          // 愛だけはある男（ボロ小屋＋もやし＋妻）
            set(.muscle, xp: 0); set(.money, xp: 0); set(.love, xp: 700)
        case "kinniku_rich":     // 筋肉と生きる男（ビル＋マッチョ＋独身）
            set(.muscle, xp: 1600); set(.money, xp: 1600); set(.love, xp: 0)
        case "kane_dake":        // 金しか勝たん男（ビル＋普通の体＋独身）
            set(.muscle, xp: 130); set(.money, xp: 1600); set(.love, xp: 0)
        case "zenmax":           // 豪邸＋ゴリマッチョ＋家族全員（勝利1歩手前）
            set(.muscle, xp: 3000); set(.money, xp: 3000); set(.love, xp: 2999)
        case "seishun":          // 青春の風が吹く直前（愛Lv1まであと僅か）
            set(.muscle, xp: 60); set(.money, xp: 60); set(.love, xp: 100)
        case "winner_ready":     // 全パラメータ勝利直前
            set(.muscle, xp: 2990); set(.money, xp: 3000); set(.love, xp: 3000)
        case "rockbottom_ready": // どん底直前
            set(.muscle, xp: 0); set(.money, xp: 0); set(.love, xp: 0)
        default:
            break
        }
    }
}
