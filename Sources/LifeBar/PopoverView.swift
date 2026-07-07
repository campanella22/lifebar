import SwiftUI
import LifeBarCore

struct PopoverView: View {
    @EnvironmentObject var appState: AppState
    @State private var showDetail = false

    var body: some View {
        VStack(spacing: 10) {
            SceneView(
                muscleLevel: appState.level(.muscle),
                moneyLevel: appState.level(.money),
                loveLevel: appState.level(.love)
            )
            Text(appState.title)
                .font(.system(.headline, design: .rounded))

            VStack(spacing: 6) {
                gauge("💪", .muscle)
                gauge("💰", .money)
                gauge("❤️", .love)
            }

            if appState.isStudying {
                HStack(spacing: 12) {
                    // TimelineView で1秒ごとに再描画（elapsedText は @Published でないため）
                    TimelineView(.periodic(from: .now, by: 1)) { _ in
                        Text("⏱ \(appState.elapsedText ?? "")")
                            .font(.system(.title3, design: .monospaced))
                    }
                    Button("■ 停止") { appState.stop() }
                        .buttonStyle(.borderedProminent)
                }
            } else {
                VStack(spacing: 4) {
                    Text("今日はどれに人生を賭ける？")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    HStack(spacing: 10) {
                        startButton("💪", .muscle)
                        startButton("💰", .money)
                        startButton("❤️", .love)
                    }
                }
            }

            HStack {
                Spacer()
                Button("⋯") { showDetail = true }
                    .buttonStyle(.plain)
                    .foregroundStyle(.secondary)
                    .help("統計・設定")
            }
        }
        .padding(12)
        .frame(width: 220)
        .sheet(isPresented: $showDetail) {
            DetailView().environmentObject(appState)
        }
        .overlay {
            // サマリー優先、その後にイベントカードを順番に表示
            if let summary = appState.summary {
                SummaryCardView(summary: summary) { appState.dismissSummary() }
            } else if let event = appState.eventQueue.first {
                EventCardView(event: event) { appState.dismissEvent() }
            }
        }
    }

    private func gauge(_ emoji: String, _ p: Param) -> some View {
        let ps = appState.state.params[p]!
        return VStack(spacing: 1) {
            HStack(spacing: 6) {
                Text(emoji).font(.caption)
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 3).fill(.quaternary)
                        RoundedRectangle(cornerRadius: 3)
                            .fill(.tint)
                            .frame(width: geo.size.width * LifeEngine.progress(xp: ps.xp, level: ps.level))
                    }
                }
                .frame(height: 8)
                Text("Lv\(ps.level)")
                    .font(.caption.monospacedDigit())
                    .frame(width: 28, alignment: .trailing)
            }
            // バーは「次のLvまでの進捗」。残りを明示する
            Text(nextLevelText(ps))
                .font(.caption2.monospacedDigit())
                .foregroundStyle(.tertiary)
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
    }

    private func nextLevelText(_ ps: ParamState) -> String {
        guard let remain = LifeEngine.xpToNextLevel(xp: ps.xp, level: ps.level) else {
            return "MAX！"
        }
        return "Lv\(ps.level + 1)まで あと\(Int(remain.rounded(.up)))XP"
    }

    private func startButton(_ emoji: String, _ p: Param) -> some View {
        Button {
            appState.start(p)
        } label: {
            Text(emoji).font(.title2).frame(width: 44, height: 36)
        }
        .buttonStyle(.bordered)
    }
}
