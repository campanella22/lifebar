import Foundation
import LifeBarCore

/// -demoState 起動引数で代表状態を再現する（デバッグ用）
enum DemoPresets {
    static func apply(name: String, to state: inout LifeState) {
        func set(_ p: Param, xp: Double) {
            state.params[p] = ParamState(xp: xp, level: LifeEngine.level(forXP: xp, currentLevel: 0))
        }
        switch name {
        case "mukimuki":         // ムキムキ無職・独身
            set(.muscle, xp: 1600); set(.money, xp: 0); set(.love, xp: 0)
        case "family":           // 家族持ち
            set(.muscle, xp: 700); set(.money, xp: 700); set(.love, xp: 1600)
        case "winner_ready":     // 全パラメータ勝利直前
            set(.muscle, xp: 2990); set(.money, xp: 3000); set(.love, xp: 3000)
        case "rockbottom_ready": // どん底直前
            set(.muscle, xp: 0); set(.money, xp: 0); set(.love, xp: 0)
        default:
            break
        }
    }
}
