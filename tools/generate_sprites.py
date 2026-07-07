#!/usr/bin/env python3
"""LifeBar のドット絵を生成する。Python 標準ライブラリのみ使用。
絵柄: 初代マリオ風（明るい空・雲・草むら・レンガの地面・輪郭線つきチビキャラ）
実行: python3 tools/generate_sprites.py
出力: Sources/LifeBar/Resources/sprites/*.png
"""
import struct
import zlib
from pathlib import Path

OUT = Path(__file__).resolve().parent.parent / "Sources/LifeBar/Resources/sprites"

# ---- パレット（初代マリオ風の発色） ----
C = {
    ".": (0, 0, 0, 0),          # 透明
    "K": (34, 32, 52, 255),     # 輪郭・髪・靴
    "S": (252, 216, 168, 255),  # 肌
    "W": (255, 255, 255, 255),  # シャツ・雲・壁
    "B": (32, 96, 220, 255),    # ズボン
    "G": (120, 120, 128, 255),  # ダンベル
    "Y": (252, 188, 0, 255),    # 金・月
    "R": (216, 40, 0, 255),     # ハート・赤屋根・妻服
    "P": (248, 120, 184, 255),  # 彼女服
    "N": (136, 88, 24, 255),    # ドア・木
    "L": (0, 168, 0, 255),      # 芝生
    "l": (0, 120, 0, 255),      # 草むら（濃い緑）
    "D": (90, 90, 100, 255),    # 屋根グレー
    "Q": (92, 148, 252, 255),   # 空（マリオの空色）
    "q": (200, 228, 255, 255),  # 窓ガラス
    "O": (200, 96, 32, 255),    # レンガ
    "o": (120, 48, 8, 255),     # レンガの目地
}


class Canvas:
    """(r,g,b,a) ピクセルの2次元キャンバス"""

    def __init__(self, w, h, fill=(0, 0, 0, 0)):
        self.w, self.h = w, h
        self.px = [[fill] * w for _ in range(h)]

    def set(self, x, y, color):
        if 0 <= x < self.w and 0 <= y < self.h:
            self.px[y][x] = color

    def rect(self, x, y, w, h, color):
        for yy in range(y, y + h):
            for xx in range(x, x + w):
                self.set(xx, yy, color)

    def blit(self, other, ox, oy):
        for y in range(other.h):
            for x in range(other.w):
                p = other.px[y][x]
                if p[3] != 0:
                    self.set(ox + x, oy + y, p)

    def scaled(self, k):
        c = Canvas(self.w * k, self.h * k)
        for y in range(self.h):
            for x in range(self.w):
                c.rect(x * k, y * k, k, k, self.px[y][x])
        return c


def outlined(c, color=None):
    """不透明部分の周囲1pxに輪郭線を引く（視認性アップ）"""
    color = color or C["K"]
    out = Canvas(c.w, c.h)
    out.blit(c, 0, 0)
    for y in range(c.h):
        for x in range(c.w):
            if c.px[y][x][3] == 0:
                for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                    nx, ny = x + dx, y + dy
                    if 0 <= nx < c.w and 0 <= ny < c.h and c.px[ny][nx][3] != 0:
                        out.px[y][x] = color
                        break
    return out


def write_png(path, canvas):
    raw = b""
    for row in canvas.px:
        raw += b"\x00" + b"".join(struct.pack("4B", *p) for p in row)

    def chunk(tag, data):
        return (struct.pack(">I", len(data)) + tag + data
                + struct.pack(">I", zlib.crc32(tag + data)))

    png = b"".join([
        b"\x89PNG\r\n\x1a\n",
        chunk(b"IHDR", struct.pack(">IIBBBBB", canvas.w, canvas.h, 8, 6, 0, 0, 0)),
        chunk(b"IDAT", zlib.compress(raw)),
        chunk(b"IEND", b""),
    ])
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_bytes(png)


# ---- メニューバー用の男（18×18 論理、@2x=36px 出力） ----
# 頭でかチビキャラ。体型パラメータ: (胴の幅, 腕の太さ)
BODY = {0: (4, 1), 1: (5, 1), 2: (6, 2), 3: (7, 2), 4: (9, 3)}


def draw_guy(level, state, frame):
    """18×18 のチビキャラ。state: idle/muscle/money/love/weak"""
    c = Canvas(18, 18)
    torso, arm = BODY[level]
    cx = 9
    bounce = 1 if (state in ("idle", "money", "love") and frame == 1) else 0
    slump = 1 if state == "weak" else 0     # うなだれ
    top = 2 + bounce + slump                # 頭のてっぺん
    # 頭（でかい）
    c.rect(cx - 4, top, 8, 2, C["K"])       # 髪
    c.rect(cx - 4, top + 2, 8, 4, C["S"])   # 顔
    c.set(cx - 2, top + 3, C["K"])          # 左目
    c.set(cx + 1, top + 3, C["K"])          # 右目
    # 胴
    torso_y = top + 6
    c.rect(cx - torso // 2, torso_y, torso, 5, C["W"])
    # 腕
    if state == "muscle":                   # 筋トレ: バーベルを頭上で上げ下げ
        press = 0 if frame == 0 else 1
        bar_y = top - 2 + press
        bar_x = cx - torso // 2 - arm - 1
        bar_w = torso + arm * 2 + 2
        c.rect(bar_x, bar_y, bar_w, 1, C["G"])              # バー
        c.rect(bar_x - 1, bar_y - 1, 1, 3, C["G"])          # 左プレート
        c.rect(bar_x + bar_w, bar_y - 1, 1, 3, C["G"])      # 右プレート
        c.rect(cx - torso // 2 - arm, bar_y + 1, arm, 3, C["S"])
        c.rect(cx + torso // 2, bar_y + 1, arm, 3, C["S"])
    else:
        ay = torso_y + (2 if state == "weak" else 0)
        c.rect(cx - torso // 2 - arm, ay, arm, 4, C["S"])
        c.rect(cx + torso // 2, ay, arm, 4, C["S"])
    # 脚と靴
    legs_y = torso_y + 5
    leg_h = 3 - bounce
    c.rect(cx - torso // 2, legs_y, 2, leg_h, C["B"])
    c.rect(cx + torso // 2 - 2, legs_y, 2, leg_h, C["B"])
    c.rect(cx - torso // 2, legs_y + leg_h, 2, 1, C["K"])
    c.rect(cx + torso // 2 - 2, legs_y + leg_h, 2, 1, C["K"])
    # 状態の小道具（頭の右上に点滅表示）
    if state == "money" and frame == 0:
        c.rect(cx + 4, top - 1, 3, 2, C["Y"])
    if state == "love" and frame == 0:
        hx, hy = cx + 4, top - 2
        c.set(hx, hy, C["R"])
        c.set(hx + 2, hy, C["R"])
        c.rect(hx, hy + 1, 3, 1, C["R"])
        c.set(hx + 1, hy + 2, C["R"])
    return outlined(c)


def gen_menubar():
    for level in range(5):
        for state in ["idle", "muscle", "money", "love", "weak"]:
            for frame in range(2):
                c = draw_guy(level, state, frame).scaled(2)   # 36×36 = 18pt @2x
                write_png(OUT / f"mb_b{level}_{state}_f{frame}.png", c)


# ---- シーン（論理96×64、4倍で出力） ----
GROUND_Y = 52   # 芝生の上端


def draw_cloud(c, x, y):
    c.rect(x + 2, y, 8, 2, C["W"])
    c.rect(x, y + 2, 12, 2, C["W"])


def draw_bush(c, x, y):
    c.rect(x + 3, y, 6, 1, C["l"])
    c.rect(x + 1, y + 1, 10, 1, C["l"])
    c.rect(x, y + 2, 12, 1, C["l"])


def draw_house(level, canvas):
    """金Lvに応じた家。小屋→アパート→赤屋根の家→ビル→金屋根の豪邸"""
    # (幅, 高さ, 屋根色, 窓の数)
    spec = {0: (18, 12, "N", 1), 1: (22, 16, "D", 2), 2: (28, 20, "R", 4),
            3: (34, 32, "D", 9), 4: (46, 38, "Y", 12)}[level]
    w, h, roof, windows = spec
    x, ground = 92 - w, 54
    canvas.rect(x, ground - h, w, h, C["W"])                  # 壁
    canvas.rect(x - 2, ground - h - 4, w + 4, 4, C[roof])     # 屋根
    canvas.rect(x - 2, ground - h - 1, w + 4, 1, C["K"])      # 屋根の影
    if level >= 2:
        canvas.rect(x + w - 8, ground - h - 9, 4, 5, C["O"])  # 煙突
    canvas.rect(x + w // 2 - 3, ground - 8, 6, 8, C["N"])     # ドア
    canvas.set(x + w // 2 + 1, ground - 4, C["Y"])            # ドアノブ
    cols = max(2, windows // 2 if windows <= 4 else (windows + 2) // 3)
    for i in range(windows):                                  # 窓（枠つき）
        wx = x + 3 + (i % cols) * max(5, (w - 8) // cols)
        wy = ground - h + 3 + (i // cols) * 8
        canvas.rect(wx, wy, 4, 4, C["K"])
        canvas.rect(wx + 1, wy + 1, 2, 2, C["q"])


def draw_scene_bg(level):
    c = Canvas(96, 64)
    c.rect(0, 0, 96, GROUND_Y, C["Q"])          # 空
    draw_cloud(c, 8, 8)
    draw_cloud(c, 44, 14)
    draw_cloud(c, 72, 5)
    c.rect(0, GROUND_Y, 96, 3, C["L"])          # 芝生
    for y in range(GROUND_Y + 3, 64):           # レンガの地面（マリオ風）
        rel = y - GROUND_Y - 3
        band = rel // 3
        for x in range(96):
            if rel % 3 == 2 or (x + band * 4) % 8 == 7:
                c.set(x, y, C["o"])
            else:
                c.set(x, y, C["O"])
    draw_bush(c, 4, GROUND_Y - 3)               # 草むら
    draw_house(level, c)
    return c


# シーン用チビキャラの体型: (胴の幅, 腕の太さ)
BODY_BIG = {0: (6, 2), 1: (8, 2), 2: (10, 3), 3: (12, 3), 4: (14, 4)}


def draw_scene_guy(level, state="idle"):
    """シーン用の大きい男（論理24×32）。顔つき・輪郭線つき"""
    c = Canvas(24, 32)
    torso, arm = BODY_BIG[level]
    cx = 12
    c.rect(cx - 5, 0, 10, 3, C["K"])            # 髪
    c.rect(cx - 5, 3, 10, 6, C["S"])            # 顔
    c.rect(cx - 3, 5, 2, 2, C["K"])             # 左目
    c.rect(cx + 1, 5, 2, 2, C["K"])             # 右目
    c.rect(cx - torso // 2, 9, torso, 11, C["W"])   # 胴
    c.rect(cx - torso // 2 - arm, 11, arm, 8, C["S"])
    c.rect(cx + torso // 2, 11, arm, 8, C["S"])
    c.rect(cx - torso // 2, 19, torso, 1, C["K"])   # ベルト
    c.rect(cx - torso // 2, 20, 3, 9, C["B"])       # 脚
    c.rect(cx + torso // 2 - 3, 20, 3, 9, C["B"])
    c.rect(cx - torso // 2 - 1, 29, 4, 2, C["K"])   # 靴
    c.rect(cx + torso // 2 - 3, 29, 4, 2, C["K"])
    return outlined(c)


def draw_person(h, dress, hair="K"):
    """同伴者（高さ h の簡易人型）: 髪・顔・目・服・靴つき"""
    c = Canvas(h // 2 + 4, h)
    cx = c.w // 2
    head = max(4, h * 2 // 5)
    c.rect(cx - head // 2, 0, head, 2, C[hair])           # 髪
    c.rect(cx - head // 2, 2, head, head - 2, C["S"])     # 顔
    c.set(cx - 1, 3, C["K"])                              # 左目
    c.set(cx + 1, 3, C["K"])                              # 右目
    c.rect(cx - head // 2 - 1, head, head + 2, h - head - 2, C[dress])  # 服
    c.rect(cx - head // 2, h - 2, 2, 2, C["K"])           # 靴
    c.rect(cx + head // 2 - 2, h - 2, 2, 2, C["K"])
    return outlined(c)


def draw_love_group(level):
    """Lv1=彼女 Lv2=妻 Lv3=妻+子供 Lv4=妻+子供+孫"""
    c = Canvas(40, 32)
    if level == 1:
        c.blit(draw_person(20, "P"), 2, 12)
    if level >= 2:
        c.blit(draw_person(22, "R"), 2, 10)
    if level >= 3:
        c.blit(draw_person(12, "B"), 16, 20)
    if level >= 4:
        c.blit(draw_person(10, "L"), 28, 22)
    return c


def draw_ending(kind):
    c = Canvas(96, 64)
    if kind == "victory":
        c.rect(0, 0, 96, 64, C["Y"])
        c.blit(draw_scene_guy(4), 20, 26)
        c.blit(draw_love_group(4), 46, 28)
        for (x, y) in [(10, 8), (30, 14), (52, 6), (74, 12), (86, 20)]:  # 星
            c.set(x, y, C["W"])
            c.set(x + 1, y, C["W"])
            c.set(x, y + 1, C["W"])
    else:  # rockbottom
        c.rect(0, 0, 96, 56, C["K"])
        c.rect(0, 56, 96, 8, C["N"])
        c.rect(78, 6, 8, 8, C["Y"])                     # 月
        for (x, y) in [(12, 10), (30, 6), (50, 14), (66, 4)]:  # 星
            c.set(x, y, C["W"])
        c.blit(draw_scene_guy(0), 30, 26)
        c.rect(46, 44, 8, 6, C["N"])                    # カバン
    return c


def gen_scene():
    for lv in range(5):
        write_png(OUT / f"scene_bg_{lv}.png", draw_scene_bg(lv).scaled(4))
        write_png(OUT / f"scene_guy_{lv}.png", draw_scene_guy(lv).scaled(4))
    for lv in range(1, 5):
        write_png(OUT / f"scene_love_{lv}.png", draw_love_group(lv).scaled(4))
    write_png(OUT / "ending_victory.png", draw_ending("victory").scaled(4))
    write_png(OUT / "ending_rockbottom.png", draw_ending("rockbottom").scaled(4))
    # アプリアイコン用（512px）: Lv3 の男をドンと
    icon = Canvas(32, 32)
    icon.rect(0, 0, 32, 32, C["Q"])
    icon.blit(draw_scene_guy(3), 4, 0)
    write_png(OUT / "icon_512.png", icon.scaled(16))


if __name__ == "__main__":
    gen_menubar()
    gen_scene()
    print(f"generated → {OUT}")
