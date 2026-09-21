import Foundation

enum Lang: String, Codable, CaseIterable {
    case pt, en
}

enum TimerStatus: String, Codable {
    case running, fired, dismissed
}

struct PrumoTimer: Identifiable, Codable, Equatable {
    var id: String
    var title: String
    var durationMs: Int
    var startedAt: Int
    var endsAt: Int
    var status: TimerStatus
}

struct Settings: Codable, Equatable {
    var language: Lang
    var showCountdown: Bool
    var showSeconds: Bool
    var snap: Bool
    var sound: Bool
    var notifications: Bool
    var seenOnboarding: Bool

    static let `default` = Settings(
        language: .pt,
        showCountdown: true,
        showSeconds: true,
        snap: true,
        sound: true,
        notifications: false,
        seenOnboarding: false
    )
}

struct PersistedState: Codable {
    var timers: [PrumoTimer]
    var settings: Settings
}

enum Copy {
    static func untitled(_ lang: Lang) -> String { lang == .pt ? "Sem nome" : "Untitled" }
    static func now(_ lang: Lang) -> String { lang == .pt ? "Agora" : "Now" }
    static func later(_ lang: Lang) -> String { lang == .pt ? "Depois" : "Later" }
    static func settings(_ lang: Lang) -> String { lang == .pt ? "Ajustes" : "Settings" }
    static func about(_ lang: Lang) -> String { lang == .pt ? "Sobre" : "About" }
    static func quit(_ lang: Lang) -> String { lang == .pt ? "Sair" : "Quit" }
    static func cancel(_ lang: Lang) -> String { lang == .pt ? "Cancelar" : "Cancel" }
    static func done(_ lang: Lang) -> String { lang == .pt ? "Pronto" : "Done" }
    static func empty(_ lang: Lang) -> String {
        lang == .pt ? "Clique num tempo ou puxe o prumo." : "Pick a time or pull the plumb."
    }
    static func pull(_ lang: Lang) -> String { lang == .pt ? "Puxar prumo" : "Pull plumb" }
    static func quick(_ lang: Lang) -> String { lang == .pt ? "Rápido" : "Quick" }
    static func shortcutsTitle(_ lang: Lang) -> String {
        lang == .pt ? "Enquanto puxa" : "While pulling"
    }
    static func shortcutPlain(_ lang: Lang) -> String {
        lang == .pt ? "Sem tecla — minutos" : "No modifier — minutes"
    }
    static func shortcutShift(_ lang: Lang) -> String {
        lang == .pt ? "⇧ Shift — minutos precisos, sem encaixe" : "⇧ Shift — exact minutes, no snap"
    }
    static func shortcutOption(_ lang: Lang) -> String {
        lang == .pt ? "⌥ Option — horas" : "⌥ Option — hours"
    }
    static func shortcutEsc(_ lang: Lang) -> String {
        lang == .pt ? "Esc — cancela o gesto" : "Esc — cancel the pull"
    }
    static func firedBody(_ lang: Lang) -> String {
        lang == .pt ? "Tempo esgotado." : "Time is up."
    }
    static func namePlaceholder(_ lang: Lang) -> String {
        lang == .pt ? "Nome do timer" : "Timer name"
    }
    static func skipName(_ lang: Lang) -> String { lang == .pt ? "Sem nome" : "Untitled" }
    static func confirmName(_ lang: Lang) -> String { lang == .pt ? "Começar" : "Start" }
    static func countdown(_ lang: Lang) -> String { lang == .pt ? "Contagem na barra" : "Countdown in bar" }
    static func seconds(_ lang: Lang) -> String { lang == .pt ? "Mostrar segundos" : "Show seconds" }
    static func snap(_ lang: Lang) -> String { lang == .pt ? "Encaixar minutos" : "Snap minutes" }
    static func sound(_ lang: Lang) -> String { lang == .pt ? "Som" : "Sound" }
    static func notifications(_ lang: Lang) -> String { lang == .pt ? "Notificações" : "Notifications" }
    static func language(_ lang: Lang) -> String { lang == .pt ? "Idioma" : "Language" }
    static func originality(_ lang: Lang) -> String {
        lang == .pt
            ? "Prumo é original: nome, ícone, textos e gesto em metáfora de prumo. Não é o Gestimer."
            : "Prumo is original: name, icon, copy, and a plumb-bob metaphor. It is not Gestimer."
    }
}
