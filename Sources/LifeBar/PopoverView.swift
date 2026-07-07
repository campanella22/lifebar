import SwiftUI
import LifeBarCore

struct PopoverView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        VStack(spacing: 8) {
            Text(appState.title).font(.headline)
            Text("PopoverView 本実装は Task 12")
        }
        .padding()
        .frame(width: 240)
    }
}
