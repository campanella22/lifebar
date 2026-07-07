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


if __name__ == "__main__":
    gen_menubar()
    print(f"generated → {OUT}")
