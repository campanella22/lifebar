/// レベルの組み合わせから称号を決める。上から順に最初にマッチしたものを返す
public enum TitleRule {
    public static func title(muscle: Int, money: Int, love: Int) -> String {
        if muscle == 4 && money == 4 && love == 4 { return "人生の勝者" }
        if muscle >= 3 && money == 0 && love == 0 { return "ムキムキ無職・独身" }
        if muscle >= 3 && money == 0 { return "ムキムキ無職" }
        if money >= 3 && muscle == 0 { return "痩せた社長" }
        if love >= 2 && muscle == 0 && money == 0 { return "愛だけはある男" }
        if muscle >= 3 && love == 0 { return "筋肉と生きる男" }
        if money >= 3 && love == 0 { return "金しか勝たん男" }
        if muscle == 0 && money == 0 && love == 0 { return "ただの男" }
        // フォールバック: 一番高いパラメータで決める
        let top = max(muscle, money, love)
        if top == muscle { return "鍛える男" }
        if top == money { return "稼ぐ男" }
        return "愛に生きる男"
    }
}
