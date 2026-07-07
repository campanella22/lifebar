# LifeBar 💪💰❤️

**勉強すればするほど、メニューバーの男の人生が良くなっていくタイマー。サボると彼女に振られます。**

A macOS menu bar study timer where a pixel-art guy's life improves as you study — and falls apart when you slack off.

![demo](docs/media/demo.png)

## 遊び方 / How it works

1. メニューバーの男をクリックして、今日の勉強を **💪筋肉 / 💰金 / ❤️愛** のどれに賭けるか選ぶ
2. 勉強する（1分 = 1XP）
3. 男が成長する: ムキムキになる → 就職する → 彼女ができる → 結婚 → 子供 → 孫
4. **サボると人生が減衰する**（1時間に1XP）。目安: 1日72分の勉強で現状維持
5. 放置しすぎると: リバウンド / 倒産 / 妻が家を出て行く……
6. 全部 MAX で「人生の勝者」。全部ゼロのまま3日で、男は田舎に帰る

「ムキムキ無職・独身」「痩せた社長」など、育て方の偏りは称号で表彰されます。

## インストール / Install

[Releases](../../releases) から `LifeBar.zip` をダウンロード → 展開 → アプリケーションフォルダへ。
署名なしのため初回は **右クリック → 開く** で起動してください。

### ソースからビルド / Build from source

```bash
git clone <this repo> && cd lifebar
make run        # ビルドして dist/LifeBar.app を起動
make test       # ユニットテスト
make sprites    # ドット絵の再生成（Python 3 標準ライブラリのみ）
```

### デバッグ / Debug

```bash
# 時間を600倍速にして人生の栄枯盛衰を数分で見る
dist/LifeBar.app/Contents/MacOS/LifeBar -timeScale 600
# 代表状態で起動: mukimuki / family / winner_ready / rockbottom_ready
swift run LifeBar -demoState mukimuki
```

## しくみ / Design

- 減衰はタイムスタンプ差分の遅延計算（常駐処理・ネットワークなし、データはローカル JSON のみ）
- ゲームバランスは [`Balance.swift`](Sources/LifeBarCore/Balance.swift) に全部入っています。改造歓迎
- ドット絵はすべて [`tools/generate_sprites.py`](tools/generate_sprites.py)（Python 標準ライブラリのみ）で生成
- 設計ドキュメント: [docs/superpowers/specs/](docs/superpowers/specs/)

## License

MIT
