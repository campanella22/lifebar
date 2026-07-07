#!/usr/bin/env python3
"""README 用ヒーロー画像を生成する（栄光と転落の2パネル）。
実行: python3 tools/generate_readme_image.py
出力: docs/media/demo.png
"""
from pathlib import Path

import sys
sys.path.insert(0, str(Path(__file__).resolve().parent))
from generate_sprites import (  # noqa: E402
    C, Canvas, draw_love_group, draw_scene_bg, draw_scene_guy, write_png,
)

OUT = Path(__file__).resolve().parent.parent / "docs/media/demo.png"


def panel_glory():
    """勉強した男: 豪邸・ゴリマッチョ・家族"""
    c = draw_scene_bg(4)
    c.blit(draw_scene_guy(4), 4, 26)
    c.blit(draw_love_group(4), 26, 28)
    return c


def panel_fall():
    """サボった男: 夜・もやし・ひとり"""
    c = Canvas(96, 64)
    c.rect(0, 0, 96, 56, C["K"])
    c.rect(0, 56, 96, 8, C["N"])
    c.rect(78, 6, 8, 8, C["Y"])        # 月
    c.blit(draw_scene_guy(0), 34, 26)
    c.rect(50, 44, 8, 6, C["N"])       # カバン
    return c


if __name__ == "__main__":
    gap = 4
    sheet = Canvas(96 * 2 + gap, 64, fill=(255, 255, 255, 255))
    sheet.blit(panel_glory(), 0, 0)
    sheet.blit(panel_fall(), 96 + gap, 0)
    write_png(OUT, sheet.scaled(4))
    print(f"generated → {OUT}")
