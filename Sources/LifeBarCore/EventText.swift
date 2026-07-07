/// イベントカード・通知の文言テーブル
public enum EventText {
    // インデックスは [Lv1, Lv2, Lv3, Lv4]
    static let upTexts: [Param: [String]] = [
        .muscle: ["体が締まってきた！", "腹筋が割れた！", "マッチョになった！", "ゴリマッチョ完成！"],
        .money: ["バイトに受かった！", "就職が決まった！", "起業して社長になった！", "豪邸を買った！"],
        .love: ["彼女ができた！", "結婚した！", "子供が生まれた！", "孫に囲まれている！"],
    ]
    // インデックスは転落前のレベル [Lv1から, Lv2から, Lv3から, Lv4から]
    static let downTexts: [Param: [String]] = [
        .muscle: ["もやしに戻った……", "腹が出てきた……", "リバウンドした……", "三段腹になった……"],
        .money: ["バイトをクビになった……", "会社が倒産した……", "事業が傾き借金取りが来た……", "豪邸が差し押さえられた……"],
        .love: ["彼女に振られた……", "妻が家を出て行った……", "子供が口をきいてくれない……", "孫が来なくなった……"],
    ]
    static let warningTexts: [Param: String] = [
        .muscle: "筋肉が落ちてきている……",
        .money: "金回りが悪くなってきた……",
        .love: "愛が冷めかけている……",
    ]

    public static func text(for kind: LifeEvent.Kind) -> String {
        switch kind {
        case .levelUp(let p, let to):
            return upTexts[p]![to - 1]
        case .levelDown(let p, let from, _):
            return downTexts[p]![from - 1]
        case .warning(let p):
            return warningTexts[p]!
        case .victory:
            return "すべてを手に入れた。人生の勝者！"
        case .rockBottom:
            return "男は田舎に帰った……"
        }
    }
}
