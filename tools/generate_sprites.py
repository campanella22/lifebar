#!/usr/bin/env python3
"""LifeBar のドット絵を生成する。Python 標準ライブラリのみ使用。
実行: python3 tools/generate_sprites.py
出力: Sources/LifeBar/Resources/sprites/*.png
"""
import struct
import zlib
from pathlib import Path

OUT = Path(__file__).resolve().parent.parent / "Sources/LifeBar/Resources/sprites"

# ---- パレット（キャッチーな少色構成） ----
C = {
    ".": (0, 0, 0, 0),          # 透明
    "K": (34, 32, 52, 255),     # 輪郭・髪
    "S": (242, 199, 155, 255),  # 肌
    "W": (255, 255, 255, 255),  # シャツ
    "B": (59, 93, 201, 255),    # ズボン
    "G": (120, 120, 128, 255),  # ダンベル
    "Y": (255, 214, 64, 255),   # 金
    "R": (231, 76, 90, 255),    # ハート・服
    "P": (240, 150, 190, 255),  # 彼女服
    "N": (139, 108, 66, 255),   # 木・地面
    "L": (140, 200, 90, 255),   # 草
    "D": (90, 90, 100, 255),    # 屋根グレー
    "Q": (150, 200, 255, 255),  # 空・窓
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
# 体型パラメータ: (肩の広がり, 腕の太さ, 胴の幅)  Lv0=もやし → Lv4=ゴリマッチョ
BODY = {0: (0, 1, 2), 1: (0, 1, 3), 2: (1, 1, 4), 3: (1, 2, 5), 4: (2, 3, 6)}


def draw_guy(level, state, frame):
    """18×18 の男を描く。state: idle/muscle/money/love/weak"""
    c = Canvas(18, 18)
    shoulder, arm, torso = BODY[level]
    cx = 9                                  # 中心
    bounce = 1 if (state == "idle" and frame == 1) else 0
    slump = 2 if state == "weak" else 0     # うなだれ
    head_y = 2 + bounce + slump
    # 頭（髪＋肌）
    c.rect(cx - 2, head_y, 4, 2, C["K"])
    c.rect(cx - 2, head_y + 2, 4, 2, C["S"])
    # 胴（シャツ）
    torso_y = head_y + 4
    c.rect(cx - torso // 2, torso_y, torso, 5, C["W"])
    # 腕（肌色、体の左右。frame で上下に振る）
    arm_dy = 0 if frame == 0 else 1
    if state == "muscle":                   # 筋トレ: バーベルを頭上に上げ下げ
        press = 0 if frame == 0 else 2      # frame1 で押し下げ
        bar_y = head_y - 2 + press
        bar_x = cx - torso // 2 - arm - 1
        bar_w = torso + arm * 2 + 2
        c.rect(bar_x, bar_y, bar_w, 1, C["G"])                 # バー
        c.rect(bar_x - 1, bar_y - 1, 1, 3, C["G"])             # 左プレート
        c.rect(bar_x + bar_w, bar_y - 1, 1, 3, C["G"])         # 右プレート
        c.rect(cx - torso // 2 - arm, bar_y + 1, arm, torso_y - bar_y - 1, C["S"])  # 左腕（垂直）
        c.rect(cx + torso // 2, bar_y + 1, arm, torso_y - bar_y - 1, C["S"])        # 右腕（垂直）
    else:
        ay = torso_y + 1 + (2 if state == "weak" else arm_dy)
        c.rect(cx - torso // 2 - arm, ay, arm, 4, C["S"])
        c.rect(cx + torso // 2, ay, arm, 4, C["S"])
    # 脚（ズボン）
    legs_y = torso_y + 5
    c.rect(cx - torso // 2, legs_y, 2, 4 - bounce, C["B"])
    c.rect(cx + torso // 2 - 2, legs_y, 2, 4 - bounce, C["B"])
    # 状態の小道具
    if state == "money":                    # 札束（点滅）
        if frame == 0:
            c.rect(cx + torso // 2 + arm, torso_y + 1, 3, 2, C["Y"])
    if state == "love":                     # ハート（点滅）
        if frame == 0:
            hx = cx + torso // 2 + arm + 1
            hy = torso_y - 3
            c.set(hx, hy, C["R"])
            c.set(hx + 2, hy, C["R"])
            c.rect(hx, hy + 1, 3, 1, C["R"])
            c.set(hx + 1, hy + 2, C["R"])
    return c


def gen_menubar():
    for level in range(5):
        for state in ["idle", "muscle", "money", "love", "weak"]:
            for frame in range(2):
                c = draw_guy(level, state, frame).scaled(2)   # 36×36 = 18pt @2x
                write_png(OUT / f"mb_b{level}_{state}_f{frame}.png", c)


def draw_house(level, canvas):
    """金Lvに応じた家を論理96×64キャンバスの右側に描く"""
    # (幅, 高さ, 屋根色, 窓の数)
    spec = {0: (18, 14, "N", 1), 1: (22, 18, "D", 2), 2: (28, 22, "R", 4),
            3: (32, 34, "D", 8), 4: (44, 38, "Y", 12)}[level]
    w, h, roof, windows = spec
    x, ground = 92 - w, 56
    canvas.rect(x, ground - h, w, h, C["W"])               # 壁
    canvas.rect(x - 2, ground - h - 4, w + 4, 4, C[roof])  # 屋根
    canvas.rect(x + w // 2 - 2, ground - 6, 4, 6, C["N"])  # ドア
    col = max(2, windows // 2)
    for i in range(windows):                               # 窓
        wx = x + 3 + (i % col) * ((w - 6) // col)
        wy = ground - h + 3 + (i // col) * 7
        canvas.rect(wx, wy, 3, 3, C["Q"])


def draw_scene_bg(level):
    c = Canvas(96, 64)
    c.rect(0, 0, 96, 56, C["Q"])       # 空
    c.rect(0, 56, 96, 8, C["L"])       # 地面
    draw_house(level, c)
    return c


def draw_person(h, dress, hair="K"):
    """同伴者（高さ h の簡易人型）: 頭2/5、服3/5"""
    c = Canvas(h // 2 + 2, h)
    cx = c.w // 2
    head = max(3, h * 2 // 5)
    c.rect(cx - head // 2, 0, head, 2, C[hair])
    c.rect(cx - head // 2, 2, head, head - 2, C["S"])
    c.rect(cx - head // 2 - 1, head, head + 2, h - head, C[dress])
    return c


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


def draw_scene_guy(level, state="idle"):
    """シーン用の大きい男（論理24×32）。体型は BODY を一回り大きく"""
    c = Canvas(24, 32)
    shoulder, arm, torso = BODY[level]
    torso = torso + 3          # シーン用に一回り大きく
    arm = arm + 1
    cx = 12
    c.rect(cx - 3, 2, 6, 4, C["K"])
    c.rect(cx - 3, 6, 6, 4, C["S"])
    c.rect(cx - torso // 2, 10, torso, 10, C["W"])
    c.rect(cx - torso // 2 - arm, 12, arm, 8, C["S"])
    c.rect(cx + torso // 2, 12, arm, 8, C["S"])
    c.rect(cx - torso // 2, 20, 3, 9, C["B"])
    c.rect(cx + torso // 2 - 3, 20, 3, 9, C["B"])
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
