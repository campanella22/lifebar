import SwiftUI
import LifeBarCore

/// 昇格・転落・エンディングの演出カード
struct EventCardView: View {
    let event: LifeEvent
    let onDismiss: () -> Void

    private var isGood: Bool {
        switch event.kind {
        case .levelUp, .victory: return true
        default: return false
        }
    }

    private var emoji: String {
        switch event.kind {
        case .levelUp(let p, _), .levelDown(let p, _, _), .warning(let p):
            switch p {
            case .muscle: return "💪"
            case .money: return "💰"
            case .love: return "❤️"
            }
        case .victory: return "👑"
        case .rockBottom: return "🌙"
        }
    }

    /// エンディングだけ専用イラストを出す（スペック§3.2）
    private var endingImage: String? {
        switch event.kind {
        case .victory: return "ending_victory"
        case .rockBottom: return "ending_rockbottom"
        default: return nil
        }
    }

    var body: some View {
        ZStack {
            Color.black.opacity(0.55)
            VStack(spacing: 10) {
                if let name = endingImage {
                    Image(nsImage: SpriteLoader.image(name) ?? NSImage())
                        .interpolation(.none)
                        .resizable()
                        .frame(width: 168, height: 112)
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                } else {
                    Text(emoji).font(.system(size: 40))
                }
                Text(EventText.text(for: event.kind))
                    .font(.system(.body, design: .rounded).bold())
                    .multilineTextAlignment(.center)
                Button("OK") { onDismiss() }
                    .buttonStyle(.borderedProminent)
                    .tint(isGood ? .blue : .gray)
            }
            .padding(16)
            .background(RoundedRectangle(cornerRadius: 10).fill(.background))
            .padding(20)
        }
        .transition(.opacity)
    }
}
