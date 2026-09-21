import AppKit
import SwiftUI

final class DragController: NSObject {
    private let store: PrumoStore
    private weak var status: StatusItemController?
    private var overlay: OverlayWindow?
    private var overlayView: OverlayView?
    private var origin: NSPoint = .zero
    private var dragging = false
    private var activated = false
    private var localMonitor: Any?
    private var globalMonitor: Any?

    init(store: PrumoStore, status: StatusItemController) {
        self.store = store
        self.status = status
        super.init()
    }

    func begin(event: NSEvent) {
        origin = NSEvent.mouseLocation
        dragging = true
        activated = false
        status?.hidePopover()
        clearMonitors()
        localMonitor = NSEvent.addLocalMonitorForEvents(
            matching: [.leftMouseDragged, .leftMouseUp, .flagsChanged, .keyDown]
        ) { [weak self] ev in
            self?.handle(ev)
            if ev.type == .keyDown, ev.keyCode == 53 { return nil }
            return ev
        }
        globalMonitor = NSEvent.addGlobalMonitorForEvents(
            matching: [.leftMouseDragged, .leftMouseUp, .flagsChanged]
        ) { [weak self] ev in
            self?.handle(ev)
        }
    }

    private func handle(_ event: NSEvent) {
        switch event.type {
        case .leftMouseDragged, .flagsChanged:
            move(event: event)
        case .leftMouseUp:
            _ = end(event: event)
        case .keyDown where event.keyCode == 53:
            cancel()
        default:
            break
        }
    }

    func move(event: NSEvent) {
        guard dragging else { return }
        let now = NSEvent.mouseLocation
        let dy = origin.y - now.y
        if !activated {
            if dy > Mapping.activatePx {
                showOverlay()
                activated = true
            } else {
                return
            }
        }
        updateOverlay(
            at: now,
            stretch: event.modifierFlags.contains(.option),
            precise: event.modifierFlags.contains(.shift)
        )
    }

    @discardableResult
    func end(event: NSEvent) -> Bool {
        let wasActivated = activated
        let now = NSEvent.mouseLocation
        let dy = origin.y - now.y
        cancelTracking()
        guard wasActivated, dy >= Mapping.activatePx else {
            if !wasActivated { status?.togglePopover() }
            return wasActivated
        }
        let screen = NSScreen.main ?? NSScreen.screens[0]
        let stretch = event.modifierFlags.contains(.option)
        let precise = event.modifierFlags.contains(.shift)
        let raw = Mapping.dragToMinutes(distancePx: dy, viewportH: screen.frame.height, stretch: stretch)
        let minutes = Mapping.snap(raw, enabled: store.settings.snap, precise: precise)
        let ms = Mapping.minutesToMs(minutes)
        guard ms >= 15_000 else { return true }
        promptName(durationMs: ms, at: now)
        return true
    }

    private func cancel() {
        cancelTracking()
    }

    private func cancelTracking() {
        dragging = false
        activated = false
        hideOverlay()
        clearMonitors()
    }

    private func clearMonitors() {
        if let localMonitor { NSEvent.removeMonitor(localMonitor) }
        if let globalMonitor { NSEvent.removeMonitor(globalMonitor) }
        localMonitor = nil
        globalMonitor = nil
    }

    private func showOverlay() {
        let view = OverlayView()
        overlayView = view
        let win = OverlayWindow(content: view)
        overlay = win
        win.orderFrontRegardless()
    }

    private func hideOverlay() {
        overlay?.orderOut(nil)
        overlay = nil
        overlayView = nil
    }

    private func updateOverlay(at point: NSPoint, stretch: Bool, precise: Bool) {
        guard let screen = NSScreen.screens.first(where: { $0.frame.contains(point) }) ?? NSScreen.main else { return }
        overlay?.setFrame(screen.frame, display: true)
        let originScreen = status?.iconScreenFrame() ?? NSRect(x: origin.x, y: origin.y, width: 18, height: 22)
        let dy = origin.y - point.y
        let raw = Mapping.dragToMinutes(distancePx: max(0, dy), viewportH: screen.frame.height, stretch: stretch)
        let minutes = Mapping.snap(raw, enabled: store.settings.snap, precise: precise)
        overlayView?.model = OverlayView.Model(
            start: CGPoint(x: originScreen.midX, y: originScreen.minY),
            bob: CGPoint(x: originScreen.midX, y: point.y),
            label: Format.duration(Mapping.minutesToMs(minutes), lang: store.settings.language),
            screen: screen.frame
        )
        overlayView?.needsDisplay = true
    }

    private func promptName(durationMs: Int, at point: NSPoint) {
        let panel = NSPanel(
            contentRect: NSRect(x: 0, y: 0, width: 260, height: 108),
            styleMask: [.titled, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        panel.titleVisibility = .hidden
        panel.titlebarAppearsTransparent = true
        panel.isFloatingPanel = true
        panel.level = .floating
        panel.hidesOnDeactivate = false
        panel.isReleasedWhenClosed = false
        let host = NSHostingController(rootView: NamePrompt(
            durationLabel: Format.duration(durationMs, lang: store.settings.language),
            lang: store.settings.language,
            onCommit: { [weak self, weak panel] title in
                self?.store.addTimer(title: title, durationMs: durationMs)
                panel?.close()
            },
            onCancel: { [weak panel] in panel?.close() }
        ))
        panel.contentViewController = host
        var originPt = point
        originPt.x -= 130
        originPt.y -= 140
        panel.setFrameOrigin(originPt)
        panel.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
}

final class OverlayWindow: NSPanel {
    init(content: NSView) {
        super.init(
            contentRect: NSScreen.main?.frame ?? .zero,
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        isOpaque = false
        backgroundColor = .clear
        level = NSWindow.Level.statusBar
        ignoresMouseEvents = true
        collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .stationary]
        hasShadow = false
        contentView = content
    }

    override var canBecomeKey: Bool { false }
}

final class OverlayView: NSView {
    struct Model {
        var start: CGPoint
        var bob: CGPoint
        var label: String
        var screen: NSRect
    }

    var model: Model?

    override func draw(_ dirtyRect: NSRect) {
        guard let model, let window else { return }
        let start = window.convertPoint(fromScreen: model.start)
        let bob = window.convertPoint(fromScreen: model.bob)

        NSColor.white.withAlphaComponent(0.22).setStroke()
        let ghost = NSBezierPath()
        ghost.move(to: start)
        ghost.line(to: NSPoint(x: start.x, y: bob.y))
        ghost.setLineDash([3, 4], count: 2, phase: 0)
        ghost.lineWidth = 1
        ghost.stroke()

        NSColor(calibratedRed: 0.78, green: 0.45, blue: 0.22, alpha: 1).setStroke()
        let cord = NSBezierPath()
        cord.move(to: start)
        cord.line(to: bob)
        cord.lineWidth = 2
        cord.lineCapStyle = .round
        cord.stroke()

        NSColor(calibratedRed: 0.12, green: 0.13, blue: 0.15, alpha: 1).setFill()
        NSColor(calibratedRed: 0.78, green: 0.45, blue: 0.22, alpha: 1).setStroke()
        let bobRect = NSRect(x: bob.x - 8, y: bob.y - 8, width: 16, height: 16)
        let bobPath = NSBezierPath(ovalIn: bobRect)
        bobPath.lineWidth = 2
        bobPath.fill()
        bobPath.stroke()

        let attrs: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: 22, weight: .semibold),
            .foregroundColor: NSColor.white,
        ]
        let text = NSAttributedString(string: model.label, attributes: attrs)
        let size = text.size()
        let hud = NSRect(
            x: bob.x + 22,
            y: bob.y - size.height / 2 - 8,
            width: size.width + 24,
            height: size.height + 16
        )
        NSColor.black.withAlphaComponent(0.72).setFill()
        NSBezierPath(roundedRect: hud, xRadius: 10, yRadius: 10).fill()
        text.draw(at: NSPoint(x: hud.minX + 12, y: hud.minY + 8))
    }
}
