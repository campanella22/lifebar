import SwiftUI
import LifeBarCore

/// セッション終了時の「おつかれさま」カード
struct SummaryCardView: View {
    let summary: SessionSummary
    let onDismiss: () -> Void

    private var emoji: String {
        switch summary.target {
        case .muscle: return "💪"
        case .money: return "💰"
        case .love: return "❤️"
        }
    }

    private var minutesText: String {
        summary.minutes < 1 ? "1分未満" : "\(summary.minutes)分"
    }

    var body: some View {
        ZStack {
            Color.black.opacity(0.55)
            VStack(spacing: 10) {
                Text("おつかれさま！")
                    .font(.system(.headline, design: .rounded))
                Text("⏱ \(minutesText) がんばった")
                    .font(.system(.body, design: .rounded))
                Text("\(emoji) +\(summary.xpGained) XP")
                    .font(.system(.title3, design: .rounded).bold())
                if let foreshadow = summary.foreshadow {
                    Divider()
                    Text(foreshadow)
                        .font(.system(.callout, design: .serif).italic())
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                Button("OK") { onDismiss() }
                    .buttonStyle(.borderedProminent)
            }
            .padding(16)
            .background(RoundedRectangle(cornerRadius: 10).fill(.background))
            .padding(20)
        }
        .transition(.opacity)
    }
}
