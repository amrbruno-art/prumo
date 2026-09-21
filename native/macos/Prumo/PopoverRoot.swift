import SwiftUI

struct PopoverRoot: View {
    @ObservedObject var store: PrumoStore
    var onStartPull: () -> Void
    var onQuit: () -> Void
    @State private var page: Page = .list

    enum Page { case list, settings, about }

    private let presets = [1, 3, 5, 10, 15, 25, 45]

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
            Divider()
            Button(role: .destructive, action: onQuit) {
                Text(Copy.quit(lang))
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
        }
        .frame(width: 280, height: 440)
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
        return VStack(alignment: .leading, spacing: 10) {
            Text(Copy.quick(lang).uppercased())
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 16)
                .padding(.top, 10)
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 44), spacing: 6)], spacing: 6) {
                ForEach(presets, id: \.self) { minutes in
                    Button("\(minutes)m") {
                        store.addTimer(title: "", durationMs: minutes * 60_000)
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                }
            }
            .padding(.horizontal, 16)

            Button(action: onStartPull) {
                HStack {
                    Image(nsImage: PlumbIcon.image(size: 14))
                    Text(Copy.pull(lang))
                }
            }
            .buttonStyle(.borderedProminent)
            .padding(.horizontal, 16)

            shortcuts
                .padding(.horizontal, 16)
                .padding(.top, 4)

            if running.isEmpty {
                Text(Copy.empty(lang))
                    .foregroundStyle(.secondary)
                    .padding(16)
            } else {
                Text(Copy.now(lang).uppercased())
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 16)
                    .padding(.top, 4)
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
            Spacer(minLength: 0)
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
            shortcuts
                .padding(.top, 8)
        }
        .padding(8)
    }

    private var shortcuts: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(Copy.shortcutsTitle(lang))
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(Copy.shortcutPlain(lang)).font(.caption)
            Text(Copy.shortcutShift(lang)).font(.caption)
            Text(Copy.shortcutOption(lang)).font(.caption)
            Text(Copy.shortcutEsc(lang)).font(.caption)
        }
    }

    private var about: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                Text("Prumo").font(.title3.weight(.semibold))
                Text(Copy.originality(lang))
                    .font(.callout)
                Text(Copy.forceQuitNote(lang))
                    .font(.callout)
                Text("MIT © 2026 Prumo contributors")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text("AS IS. No warranty. See DISCLAIMER.md in the repository.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                shortcuts
                    .padding(.top, 8)
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
            Text(Copy.escCancels(lang))
                .font(.caption)
                .foregroundStyle(.secondary)
            TextField(Copy.namePlaceholder(lang), text: $title)
                .textFieldStyle(.roundedBorder)
                .onSubmit { onCommit(title) }
            HStack {
                Button(Copy.cancel(lang), role: .cancel, action: onCancel)
                    .keyboardShortcut(.cancelAction)
                Spacer()
                Button(Copy.skipName(lang)) { onCommit("") }
                Button(Copy.confirmName(lang)) { onCommit(title) }
                    .keyboardShortcut(.defaultAction)
            }
        }
        .padding(14)
        .frame(width: 268)
        .onExitCommand(perform: onCancel)
    }
}
