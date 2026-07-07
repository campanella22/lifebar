import AppKit
import SwiftUI
import LifeBarCore

struct DetailView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss
    @State private var confirmingReset = false

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("詳細").font(.headline)
                Spacer()
                Button("閉じる") { dismiss() }
            }
            .padding(12)
            Divider()
            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    section("📊 記録") {
                        row("今日の勉強", minutes(appState.state.todayStudyMinutes))
                        row("生涯累計", minutes(appState.state.totalStudyMinutes))
                        row("現在の人生", "\(appState.state.run)周目")
                    }
                    section("📜 最近のできごと") {
                        if appState.state.eventLog.isEmpty {
                            Text("まだ何も起きていない").foregroundStyle(.secondary)
                        }
                        ForEach(appState.state.eventLog.suffix(20).reversed()) { event in
                            HStack(alignment: .top) {
                                Text(event.date, format: .dateTime.month().day())
                                    .foregroundStyle(.secondary)
                                    .frame(width: 44, alignment: .leading)
                                Text(EventText.text(for: event.kind))
                            }
                            .font(.caption)
                        }
                    }
                    section("👑 殿堂") {
                        if appState.state.hallOfFame.isEmpty {
                            Text("まだ人生を勝ち切っていない").foregroundStyle(.secondary)
                        }
                        ForEach(appState.state.hallOfFame, id: \.run) { entry in
                            row("\(entry.run)周目", "\(minutes(entry.totalStudyMinutes))で制覇")
                        }
                    }
                    section("⚙️ 設定") {
                        Toggle("勉強中の経過時間をメニューバーに表示", isOn: settingBinding(\.showElapsed))
                        Toggle("ログイン時に起動", isOn: settingBinding(\.launchAtLogin))
                    }
                    Button("人生をリセット", role: .destructive) { confirmingReset = true }
                        .frame(maxWidth: .infinity)
                    Button("LifeBar を終了") { NSApp.terminate(nil) }
                        .frame(maxWidth: .infinity)
                }
                .padding(12)
                .font(.callout)
            }
        }
        .frame(width: 260, height: 380)
        .confirmationDialog("本当に人生をやり直しますか？（記録も全て消えます）",
                            isPresented: $confirmingReset, titleVisibility: .visible) {
            Button("やり直す", role: .destructive) { appState.resetLife(); dismiss() }
        }
    }

    private func section(_ title: String, @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title).font(.caption.bold()).foregroundStyle(.secondary)
            content()
        }
    }

    private func row(_ label: String, _ value: String) -> some View {
        HStack { Text(label); Spacer(); Text(value).foregroundStyle(.secondary) }
    }

    private func minutes(_ m: Double) -> String {
        let total = Int(m)
        return total < 60 ? "\(total)分" : "\(total / 60)時間\(total % 60)分"
    }

    private func settingBinding(_ keyPath: WritableKeyPath<UserSettings, Bool>) -> Binding<Bool> {
        Binding(
            get: { appState.state.settings[keyPath: keyPath] },
            set: { newValue in
                var s = appState.state.settings
                s[keyPath: keyPath] = newValue
                appState.updateSettings(s)
                if keyPath == \.launchAtLogin { LoginItem.apply(enabled: newValue) }
            }
        )
    }
}
