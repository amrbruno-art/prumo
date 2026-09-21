import AppKit

enum SoundPlayer {
    static func chime() {
        if let sound = NSSound(named: NSSound.Name("Tink")) {
            sound.play()
        } else {
            NSSound.beep()
        }
    }
}
