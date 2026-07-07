import AppKit
import Combine
import SwiftUI
import LifeBarCore

/// メニューバーの男。コマ送りアニメとポップオーバー開閉を担当
@MainActor
final class MenuBarController {
    private let appState: AppState
    private let statusItem: NSStatusItem
    private let popover = NSPopover()
    private var animTimer: Timer?
    private var frame = 0
    private var cancellables: Set<AnyCancellable> = []

    init(appState: AppState) {
        self.appState = appState
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusItem.button?.imagePosition = .imageLeft
        statusItem.button?.target = self
        statusItem.button?.action = #selector(togglePopover)

        popover.behavior = .transient
        popover.contentViewController = NSHostingController(
            rootView: PopoverView().environmentObject(appState)
        )

        // 0.5秒ごとに2コマアニメ
        animTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            Task { @MainActor in self?.refresh() }
        }
        appState.objectWillChange
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in self?.refresh() }
            .store(in: &cancellables)
        refresh()
    }

    private func refresh() {
        frame = (frame + 1) % 2
        let s = appState.state
        let anim: String
        if let session = s.session {
            anim = session.target.rawValue          // muscle / money / love
        } else if !s.warnedParams.isEmpty {
            anim = "weak"
        } else {
            anim = "idle"
        }
        let name = "mb_b\(s.params[.muscle]!.level)_\(anim)_f\(frame)"
        statusItem.button?.image = SpriteLoader.image(name)
        statusItem.button?.title = (s.settings.showElapsed ? appState.elapsedText : nil).map { " " + $0 } ?? ""
    }

    @objc private func togglePopover() {
        if popover.isShown {
            popover.performClose(nil)
        } else if let button = statusItem.button {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            popover.contentViewController?.view.window?.makeKey()
        }
    }
}
