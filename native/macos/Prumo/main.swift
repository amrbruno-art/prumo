import AppKit

/// Explicit run loop so the extra stays alive without a window or Dock icon.
let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.setActivationPolicy(.accessory)
app.run()
