import SwiftUI
import LifeBarCore

/// 人生の一枚絵。背景=金Lv / 男=筋肉Lv / 同伴者=愛Lv のレイヤー合成
struct SceneView: View {
    let muscleLevel: Int
    let moneyLevel: Int
    let loveLevel: Int

    var body: some View {
        ZStack(alignment: .bottom) {
            sprite("scene_bg_\(moneyLevel)")
                .resizable()
                .frame(width: 192, height: 128)
            HStack(alignment: .bottom, spacing: 6) {
                sprite("scene_guy_\(muscleLevel)")
                    .resizable()
                    .frame(width: 48, height: 64)
                if loveLevel >= 1 {
                    sprite("scene_love_\(loveLevel)")
                        .resizable()
                        .frame(width: 80, height: 64)
                }
            }
            .padding(.bottom, 18)   // 足が芝生（論理y=55付近）に乗る位置
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading, 16)
        }
        .frame(width: 192, height: 128)
        .clipShape(RoundedRectangle(cornerRadius: 6))
    }

    private func sprite(_ name: String) -> Image {
        Image(nsImage: SpriteLoader.image(name) ?? NSImage())
            .interpolation(.none)
    }
}
