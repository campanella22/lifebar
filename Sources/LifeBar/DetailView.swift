import SwiftUI

/// Task 14 で本実装
struct DetailView: View {
    @Environment(\.dismiss) var dismiss
    var body: some View {
        VStack { Text("詳細は Task 14"); Button("閉じる") { dismiss() } }
            .padding()
            .frame(width: 220, height: 160)
    }
}
