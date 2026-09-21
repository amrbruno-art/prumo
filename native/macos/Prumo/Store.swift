import Foundation
import Combine

final class PrumoStore: ObservableObject {
    @Published private(set) var timers: [PrumoTimer] = []
    @Published var settings: Settings = .default

    var onFire: ((PrumoTimer) -> Void)?

    private var ticker: Timer?
    private let url: URL

    init() {
        let dir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
            .appendingPathComponent("Prumo", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        url = dir.appendingPathComponent("state.json")
    }

    var nextRunning: PrumoTimer? {
        timers.filter { $0.status == .running }.min(by: { $0.endsAt < $1.endsAt })
    }

    func load() {
        guard let data = try? Data(contentsOf: url),
              let state = try? JSONDecoder().decode(PersistedState.self, from: data)
        else { return }
        timers = state.timers
        settings = state.settings
    }

    func save() {
        let state = PersistedState(timers: timers, settings: settings)
        if let data = try? JSONEncoder().encode(state) {
            try? data.write(to: url, options: .atomic)
        }
    }

    func startTicking() {
        ticker?.invalidate()
        let t = Timer(timeInterval: 0.25, repeats: true) { [weak self] _ in
            self?.tick()
        }
        t.tolerance = 0.05
        RunLoop.main.add(t, forMode: .common)
        ticker = t
    }

    func addTimer(title: String, durationMs: Int) {
        let now = Int(Date().timeIntervalSince1970 * 1000)
        let timer = PrumoTimer(
            id: UUID().uuidString,
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            durationMs: durationMs,
            startedAt: now,
            endsAt: now + durationMs,
            status: .running
        )
        timers.insert(timer, at: 0)
        if timers.count > 40 { timers = Array(timers.prefix(40)) }
        settings.seenOnboarding = true
        save()
        Notifier.schedule(timer, language: settings.language, enabled: settings.notifications)
    }

    func cancel(_ id: String) {
        timers.removeAll { $0.id == id }
        Notifier.cancel(id)
        save()
    }

    func patch(_ block: (inout Settings) -> Void) {
        block(&settings)
        save()
    }

    private func tick() {
        let now = Int(Date().timeIntervalSince1970 * 1000)
        var fired: [PrumoTimer] = []
        timers = timers.map { timer in
            var t = timer
            if t.status == .running, t.endsAt <= now {
                t.status = .fired
                fired.append(t)
            }
            return t
        }
        if !fired.isEmpty { save() }
        for t in fired { onFire?(t) }
        objectWillChange.send()
    }
}
