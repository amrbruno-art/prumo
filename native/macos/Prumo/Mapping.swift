import Foundation

enum Mapping {
    static let dragThresholdPx: CGFloat = 12
    static let activatePx: CGFloat = 24

    private static let shortStops: [(CGFloat, Double)] = [
        (0, 0.5), (0.06, 1), (0.11, 2), (0.16, 3), (0.22, 5), (0.3, 8),
        (0.37, 10), (0.46, 15), (0.54, 20), (0.61, 25), (0.68, 30),
        (0.76, 45), (0.83, 60), (0.91, 120), (1, 480),
    ]

    private static let longStops: [(CGFloat, Double)] = [
        (0, 5), (0.1, 15), (0.2, 30), (0.32, 60), (0.44, 120),
        (0.56, 240), (0.68, 480), (0.82, 720), (1, 1440),
    ]

    static let snapMinutes: [Double] = [
        0.5, 1, 2, 3, 4, 5, 6, 8, 10, 12, 15, 20, 25, 30, 35, 40, 45, 50, 55, 60,
        75, 90, 105, 120, 150, 180, 240, 300, 360, 480, 600, 720, 960, 1200, 1440,
    ]

    static func usableTrack(_ viewportH: CGFloat) -> CGFloat {
        max(260, viewportH - 96)
    }

    static func dragToMinutes(distancePx: CGFloat, viewportH: CGFloat, stretch: Bool) -> Double {
        let usable = usableTrack(viewportH)
        let t = clamp((distancePx - dragThresholdPx) / usable, 0, 1)
        return lerpStops(t, stretch ? longStops : shortStops)
    }

    static func snap(_ raw: Double, enabled: Bool, precise: Bool) -> Double {
        if precise {
            if raw < 5 { return (raw * 2).rounded() / 2 }
            return max(1, raw.rounded())
        }
        if !enabled { return max(0.5, (raw * 2).rounded() / 2) }
        var best = snapMinutes[0]
        var bestD = Double.infinity
        for s in snapMinutes {
            let d = abs(s - raw)
            if d < bestD {
                best = s
                bestD = d
            }
        }
        return best
    }

    static func minutesToMs(_ minutes: Double) -> Int {
        Int((minutes * 60_000).rounded())
    }

    private static func lerpStops(_ t: CGFloat, _ stops: [(CGFloat, Double)]) -> Double {
        if t <= 0 { return stops[0].1 }
        if t >= 1 { return stops[stops.count - 1].1 }
        for i in 1 ..< stops.count {
            let (r1, m1) = stops[i]
            let (r0, m0) = stops[i - 1]
            if t <= r1 {
                let u = Double((t - r0) / (r1 - r0))
                return m0 + (m1 - m0) * u
            }
        }
        return stops[stops.count - 1].1
    }

    private static func clamp(_ n: CGFloat, _ a: CGFloat, _ b: CGFloat) -> CGFloat {
        min(b, max(a, n))
    }
}

enum Format {
    static func duration(_ ms: Int, lang: Lang) -> String {
        let totalSec = max(0, Int((Double(ms) / 1000).rounded()))
        if totalSec < 60 {
            return lang == .pt ? "\(totalSec) s" : "\(totalSec)s"
        }
        let totalMin = Int((Double(totalSec) / 60).rounded())
        let hours = totalMin / 60
        let mins = totalMin % 60
        if hours == 0 { return "\(mins) min" }
        if mins == 0 { return lang == .pt ? "\(hours) h" : "\(hours)h" }
        return lang == .pt ? "\(hours) h \(mins) min" : "\(hours)h \(mins)m"
    }

    static func remaining(_ ms: Int, showSeconds: Bool) -> String {
        let totalSec = max(0, Int(ceil(Double(ms) / 1000)))
        let hours = totalSec / 3600
        let mins = (totalSec % 3600) / 60
        let secs = totalSec % 60
        func pad(_ n: Int) -> String { String(format: "%02d", n) }
        if !showSeconds {
            let roundedMin = max(1, Int(ceil(Double(totalSec) / 60)))
            if roundedMin >= 60 {
                let h = roundedMin / 60
                let m = roundedMin % 60
                return m == 0 ? "\(h)h" : "\(h)h \(pad(m))m"
            }
            return "\(roundedMin) min"
        }
        if hours > 0 { return "\(hours):\(pad(mins)):\(pad(secs))" }
        return "\(pad(mins)):\(pad(secs))"
    }

    /// Clock time when a timer of `ms` from now would fire, e.g. "10:10".
    static func endClock(_ ms: Int, lang: Lang) -> String {
        let date = Date().addingTimeInterval(TimeInterval(ms) / 1000)
        let cal = Calendar.current
        let fmt = DateFormatter()
        fmt.locale = Locale(identifier: lang == .pt ? "pt_BR" : "en_GB")
        fmt.dateFormat = "HH:mm"
        let clock = fmt.string(from: date)
        if cal.isDateInToday(date) { return clock }
        if cal.isDateInTomorrow(date) {
            return lang == .pt ? "amanhã \(clock)" : "tomorrow \(clock)"
        }
        fmt.dateFormat = lang == .pt ? "dd/MM HH:mm" : "MMM d HH:mm"
        return fmt.string(from: date)
    }
}
