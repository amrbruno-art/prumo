import AppKit
import Combine
import SwiftUI

final class StatusItemController: NSObject {
    let item: NSStatusItem
    let store: PrumoStore
    weak var drag: DragController?
    private var popover: NSPopover?
    private var cancellable: AnyCancellable?

    init(store: PrumoStore) {
        self.store = store
        item = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        super.init()
        if let button = item.button {
            button.image = PlumbIcon.image()
            button.imagePosition = .imageLeft
            button.sendAction(on: [.leftMouseDown, .rightMouseUp])
            button.target = self
            button.action = #selector(handleButton(_:))
        }
        cancellable = store.objectWillChange.sink { [weak self] _ in
            DispatchQueue.main.async { self?.rebuild() }
        }
    }

    func rebuild() {
        guard let button = item.button else { return }
        button.image = PlumbIcon.image()
        if store.settings.showCountdown, let next = store.nextRunning {
            let left = max(0, next.endsAt - Int(Date().timeIntervalSince1970 * 1000))
            button.title = " " + Format.remaining(left, showSeconds: store.settings.showSeconds)
        } else {
            button.title = ""
        }
        item.length = NSStatusItem.variableLength
    }

    @objc private func handleButton(_ sender: Any?) {
        guard let event = NSApp.currentEvent else { return }
        switch event.type {
        case .leftMouseDown:
            drag?.begin(event: event)
        case .rightMouseUp:
            togglePopover()
        default:
            break
        }
    }

    func togglePopover() {
        if popover?.isShown == true {
            popover?.performClose(nil)
            return
        }
        let pop = NSPopover()
        pop.behavior = .transient
        pop.animates = true
        pop.contentSize = NSSize(width: 280, height: 420)
        pop.contentViewController = NSHostingController(
            rootView: PopoverRoot(store: store, onQuit: { [weak self] in
                self?.popover?.performClose(nil)
                NSApp.terminate(nil)
            })
        )
        popover = pop
        if let button = item.button {
            pop.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
        }
    }

    func hidePopover() {
        popover?.performClose(nil)
    }

    func iconScreenFrame() -> NSRect {
        guard let button = item.button, let window = button.window else { return .zero }
        return window.convertToScreen(button.convert(button.bounds, to: nil))
    }
}
