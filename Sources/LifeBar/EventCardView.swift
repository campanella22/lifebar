import SwiftUI
import LifeBarCore

/// Task 13 で本実装
struct EventCardView: View {
    let event: LifeEvent
    let onDismiss: () -> Void
    var body: some View {
        Text(EventText.text(for: event.kind)).onTapGesture(perform: onDismiss)
    }
}
