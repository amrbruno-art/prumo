import AppKit

enum PlumbIcon {
    static func image(size: CGFloat = 18) -> NSImage {
        let img = NSImage(size: NSSize(width: size, height: size), flipped: false) { rect in
            NSColor.black.set()
            let mid = rect.midX
            let cord = NSBezierPath()
            cord.move(to: NSPoint(x: mid, y: rect.maxY - 1))
            cord.line(to: NSPoint(x: mid, y: rect.midY + 1))
            cord.lineWidth = 1.4
            cord.lineCapStyle = .round
            cord.stroke()
            let bobR = rect.width * 0.22
            let bob = NSBezierPath(ovalIn: NSRect(
                x: mid - bobR,
                y: rect.minY + 1.5,
                width: bobR * 2,
                height: bobR * 2
            ))
            bob.fill()
            return true
        }
        img.isTemplate = true
        return img
    }
}
