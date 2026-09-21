import SwiftUI

struct PopoverRoot: View {
    @ObservedObject var store: PrumoStore
    var onQuit: () -> Void
    @State private var page: Page = .list

    enum Page { case list, settings, about }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            header
            Divider()
            Group {
                switch page {
                case .list: list
                case .settings: settings
                case .about: about
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
        .frame(width: 280, height: 420)
        .background(Color(nsColor: .windowBackgroundColor))
    }

    private var lang: Lang { store.settings.language }

    private var header: some View {
        HStack {
            Image(nsImage: PlumbIcon.image(size: 16))
            Text("Prumo").font(.headline)
            Spacer()
            Button(Copy.settings(lang)) { page = page == .settings ? .list : .settings }
                .buttonStyle(.borderless)
            Button(Copy.about(lang)) { page = page == .about ? .list : .about }
                .buttonStyle(.borderless)
        }
        .padding(12)
    }

    private var list: some View {
        let running = store.timers.filter { $0.status == .running }
        return VStack(alignment: .leading, spacing: 8) {
            if running.isEmpty {
                Text(Copy.empty(lang))
                    .foregroundStyle(.secondary)
                    .padding(16)
            } else {
                Text(Copy.now(lang).uppercased())
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                ForEach(running) { timer in
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(timer.title.isEmpty ? Copy.untitled(lang) : timer.title)
                                .font(.body.weight(.medium))
                            Text(Format.remaining(
                                max(0, timer.endsAt - Int(Date().timeIntervalSince1970 * 1000)),
                                showSeconds: store.settings.showSeconds
                            ))
                            .font(.system(.body, design: .monospaced))
                            .foregroundStyle(.secondary)
                        }
                        Spacer()
                        Button(Copy.cancel(lang)) { store.cancel(timer.id) }
                            .buttonStyle(.borderless)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 6)
                }
            }
            Spacer()
            Button(Copy.quit(lang), action: onQuit)
                .padding(16)
        }
    }

    private var settings: some View {
        Form {
            Picker(Copy.language(lang), selection: binding(\.language)) {
                Text("Português").tag(Lang.pt)
                Text("English").tag(Lang.en)
            }
            Toggle(Copy.countdown(lang), isOn: binding(\.showCountdown))
            Toggle(Copy.seconds(lang), isOn: binding(\.showSeconds))
            Toggle(Copy.snap(lang), isOn: binding(\.snap))
            Toggle(Copy.sound(lang), isOn: binding(\.sound))
            Toggle(Copy.notifications(lang), isOn: Binding(
                get: { store.settings.notifications },
                set: { value in
                    store.patch { $0.notifications = value }
                    if value { Notifier.request() }
                }
            ))
        }
        .padding(8)
    }

    private var about: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                Text("Prumo").font(.title3.weight(.semibold))
                Text(Copy.originality(lang))
                    .font(.callout)
                Text("MIT © 2026 Prumo contributors")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text("AS IS. No warranty. See DISCLAIMER.md in the repository.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(16)
        }
    }

    private func binding<T>(_ key: WritableKeyPath<Settings, T>) -> Binding<T> {
        Binding(
            get: { store.settings[keyPath: key] },
            set: { value in store.patch { $0[keyPath: key] = value } }
        )
    }
}

struct NamePrompt: View {
    let durationLabel: String
    let lang: Lang
    var onCommit: (String) -> Void
    var onCancel: () -> Void
    @State private var title = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(durationLabel).font(.headline)
            TextField(Copy.namePlaceholder(lang), text: $title)
                .textFieldStyle(.roundedBorder)
                .onSubmit { onCommit(title) }
            HStack {
                Button(Copy.skipName(lang)) { onCommit("") }
                Spacer()
                Button(Copy.confirmName(lang)) { onCommit(title) }
                    .keyboardShortcut(.defaultAction)
            }
        }
        .padding(14)
        .frame(width: 248)
    }
}
