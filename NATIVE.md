# App nativo para macOS / Native macOS app

O que está na raiz do repositório é a **simulação web**. Isso **não** vira um app da barra de menu só empacotando o site (Electron, Tauri, PWA). A barra de menu real do macOS só existe via **AppKit** (`NSStatusItem`).

The repo root is the **web simulation**. Wrapping that site (Electron, Tauri, PWA) does **not** make a real menu-bar extra. The real macOS menu bar is **AppKit** (`NSStatusItem`).

**Sem garantia.** Ver [DISCLAIMER.md](DISCLAIMER.md). Isto não é aconselhamento jurídico nem da Apple.

---

## Português

### O caminho certo

Há um projeto Xcode em [`native/macos/`](native/macos/):

- ícone **na barra de menu real** (app acessório, sem Dock)
- puxe para baixo para definir o tempo
- painel para nomear, lista, ajustes, som e notificações do sistema
- dados em `~/Library/Application Support/Prumo/`

Isto é código original (Swift). Não copia Gestimer.

### Requisitos

- Mac com **macOS 14** ou mais novo
- **Xcode 16+** da Mac App Store (gratuito)
- Apple ID (grátis) para assinar no seu Mac
- Conta **Apple Developer** paga (US$ 99/ano) **somente** se for notarizar e distribuir para outras pessoas ou para a Mac App Store

### Compilar e instalar no seu Mac

```bash
git clone https://github.com/amrbruno-art/prumo.git
cd prumo
open native/macos/Prumo.xcodeproj
```

No Xcode:

1. Selecione o target **Prumo**.
2. Signing & Capabilities: escolha o seu **Team** (Apple ID pessoal serve para rodar aí).
3. Product → Run (⌘R).

O ícone aparece **à direita da barra de menu**. Não aparece no Dock (`LSUIElement`).

Para gerar um `.app` e pôr em Aplicativos:

1. Product → Scheme → Prumo, configuração **Release** (Product → Scheme → Edit Scheme → Run → Release, ou Archive).
2. Product → Archive.
3. Distribute App → Copy App → escolha uma pasta.
4. Arraste `Prumo.app` para `/Applications`.

Ou no terminal, no Mac:

```bash
cd native/macos
xcodebuild -scheme Prumo -configuration Release -derivedDataPath ./DerivedData
open DerivedData/Build/Products/Release/Prumo.app
```

Copie `Prumo.app` para `/Applications` se quiser.

### Abrir no login

Ajustes do Sistema → Geral → Itens de início → **+** → Prumo.

### Distribuir para outras pessoas

Sem notarização, o Gatekeeper bloqueia o `.app` em outros Macs.

1. Conta Apple Developer paga.
2. Archive no Xcode.
3. Distribute App → Direct Distribution / Developer ID, com notarização.
4. Publique o `.dmg` ou zip nos [Releases](https://github.com/amrbruno-art/prumo/releases) do GitHub.

Mac App Store é outro fluxo (sandbox já está ligado; privacidade, screenshots, revisão da Apple).

### O que **não** fazer

- **Electron / Tauri em cima da simulação web:** você teria um desktop falso *dentro* de uma janela. Não é barra de menu nativa.
- Instalar o `.app` sem ler o [DISCLAIMER.md](DISCLAIMER.md).
- Usar como alarme médico, de medicação, de criança ou de prazo legal.

### Desinstalar o nativo

Ver [UNINSTALL.md](UNINSTALL.md) § app nativo.

---

## English

### The right path

An Xcode project lives in [`native/macos/`](native/macos/):

- icon in the **real menu bar** (accessory app, no Dock icon)
- pull down to set duration
- name prompt, list, settings, sound, system notifications
- data in `~/Library/Application Support/Prumo/`

Original Swift. Not Gestimer.

### Requirements

- Mac with **macOS 14+**
- **Xcode 16+** from the Mac App Store (free)
- Apple ID (free) to sign on your machine
- Paid **Apple Developer** program (US$99/year) **only** to notarize and give the app to other people, or to ship on the Mac App Store

### Build and install

```bash
git clone https://github.com/amrbruno-art/prumo.git
cd prumo
open native/macos/Prumo.xcodeproj
```

In Xcode: pick a **Team**, Product → Run. The icon is on the **right of the menu bar**, not in the Dock.

Archive → Distribute App → Copy App → drop `Prumo.app` into `/Applications`.

### Login item

System Settings → General → Login Items → **+** → Prumo.

### Giving it to other people

Without notarization, Gatekeeper blocks the app on other Macs. Paid Developer ID + notarize, then attach a `.dmg` to GitHub Releases.

### What not to do

Do not wrap the web simulation in Electron/Tauri and call that a menu-bar extra. Do not use it as a safety-critical alarm.

### Uninstall

See [UNINSTALL.md](UNINSTALL.md) (native app section).
