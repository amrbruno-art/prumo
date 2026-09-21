import AppKit

enum PlumbIcon {
    /// Silhouette of a mason's plumb (cone + eyelet), not a drop.
    static func image(size: CGFloat = 18) -> NSImage {
        let img = NSImage(size: NSSize(width: size, height: size), flipped: false) { rect in
            NSColor.black.set()
            let mid = rect.midX
            let top = rect.maxY - 0.4
            let eyeY = rect.minY + rect.height * 0.58
            let coneTop = rect.minY + rect.height * 0.48

            let cord = NSBezierPath()
            cord.move(to: NSPoint(x: mid, y: top))
            cord.line(to: NSPoint(x: mid, y: eyeY + rect.height * 0.1))
            cord.lineWidth = max(1.1, size * 0.08)
            cord.lineCapStyle = .round
            cord.stroke()

            let eyeR = max(1.4, rect.width * 0.11)
            let eye = NSBezierPath(ovalIn: NSRect(
                x: mid - eyeR,
                y: eyeY - eyeR,
                width: eyeR * 2,
                height: eyeR * 2
            ))
            eye.lineWidth = max(1.0, size * 0.07)
            eye.stroke()

            let half = rect.width * 0.3
            let cone = NSBezierPath()
            cone.move(to: NSPoint(x: mid - half, y: coneTop))
            cone.line(to: NSPoint(x: mid + half, y: coneTop))
            cone.line(to: NSPoint(x: mid, y: rect.minY + 0.8))
            cone.close()
            cone.fill()
            return true
        }
        img.isTemplate = true
        return img
    }
}
