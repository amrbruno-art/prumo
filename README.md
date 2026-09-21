# Prumo

**Puxe. Solte. Lembre.** / **Drop the line. Keep the time.**

Timer de barra de menu de **código aberto**. Puxe o prumo na barra — quanto mais fundo, mais tempo.

Open-source menu bar timer. Pull the plumb from the menu bar — the deeper you drop it, the longer the time.

**Licença:** [MIT](LICENSE) · **Isenção:** [DISCLAIMER.md](DISCLAIMER.md) · **Marcas:** [NOTICE.md](NOTICE.md) · **Desinstalar:** [UNINSTALL.md](UNINSTALL.md) · **App nativo:** [NATIVE.md](NATIVE.md) · **Instalador:** [INSTALL.md](INSTALL.md)

> Ao usar este software você aceita o [MIT](LICENSE) e o [DISCLAIMER.md](DISCLAIMER.md).  
> **Não há garantia. Use por sua conta e risco.**

---

## Português

### O que é

Prumo é um **aplicativo web** que simula um desktop estilo macOS para você criar timers com um gesto: arrastar o ícone da barra de menu para baixo. A distância define a duração. Depois você pode dar um nome. A contagem aparece na barra. Ao terminar, há som e um aviso na tela.

Há também um **projeto Xcode nativo** (barra de menu real do macOS) em [`native/macos/`](native/macos/). Como gerar o `.app`: [NATIVE.md](NATIVE.md).

Isto **não** está na Mac App Store e **não** é um produto Apple. O `.app` nativo **não** vem pré-compilado: você constrói no Xcode no seu Mac.

### O que não é

- Não é o Gestimer nem o Gestimer 2.
- Não usa nome, ícone, textos ou artes desses produtos.
- Não sincroniza com Lembretes da Apple.
- Não serve como alarme médico, de cozinha crítico, de medicação, de criança, de transporte ou de prazo legal.

### Aviso legal (leia)

O Prumo é oferecido **no estado em que se encontra**, **sem qualquer garantia**. Os autores e o titular desta conta GitHub **não respondem** por:

- problemas judiciais, reclamações, multas ou processos de qualquer natureza;
- mau uso, uso ilegal ou uso em contexto para o qual o programa não foi feito;
- danos a computador, periféricos, tela, áudio, bateria, dados ou sistemas;
- timers que não disparem, disparem atrasados, sejam silenciados pelo navegador ou passem despercebidos;
- perda de dados no `localStorage` do navegador.

Você **assume todo o risco** e, na máxima extensão da lei, **isenta e indeniza** autores e contribuidores. Texto completo: [DISCLAIMER.md](DISCLAIMER.md). Marcas de terceiros: [NOTICE.md](NOTICE.md).

Isto **não** é aconselhamento jurídico.

### Requisitos

- [Node.js](https://nodejs.org/) **22** ou mais recente
- npm 10+ (vem com o Node)
- Um navegador atual (Chrome, Firefox, Safari, Edge)
- Opcional: permitir notificações do site no navegador

### Instalar e executar

```bash
git clone https://github.com/amrbruno-art/prumo.git
cd prumo
npm install
npm run dev
```

Abra o endereço que o terminal imprimir (em geral a porta **8080**).

Outros comandos:

```bash
npm run build        # build de produção
npm run typecheck    # TypeScript
npm run preview      # servir o build
```

Não rode como serviço de alarme em produção crítica. É um utilitário de interface, no navegador.

### App nativo (`.app` no Mac)

Empacotar este site **não** coloca um ícone na barra de menu real. O caminho nativo é Swift/AppKit.

Guia: **[NATIVE.md](NATIVE.md)**. Resumo:

```bash
git clone https://github.com/amrbruno-art/prumo.git
open native/macos/Prumo.xcodeproj
```

No Xcode: escolha o seu Team (Apple ID) → Product → Run. O prumo aparece na **barra de menu** (não no Dock).

Para instalar em `/Applications` **sem App Store** (`.dmg` / `.pkg`): **[INSTALL.md](INSTALL.md)**.

```bash
bash native/macos/scripts/package.sh
```

Ou baixe o artifact do [workflow macOS installer](https://github.com/amrbruno-art/prumo/actions/workflows/macos-installer.yml). Sem notarização, use clique direito → Abrir.

### Desinstalar

Guia completo: **[UNINSTALL.md](UNINSTALL.md)**. Resumo:

1. Web: no terminal, `Ctrl+C` / `Control+C` para parar `npm run dev`; apague a pasta do clone; limpe os dados do site no navegador (`prumo-v1`).
2. Nativo: encerrar na barra de menu, apagar `Prumo.app` de Aplicativos e a pasta `~/Library/Application Support/Prumo`.
3. Node.js e Xcode são programas separados: só os desinstale se você os colocou **apenas** para o Prumo.

### Como usar

1. (Opcional) Feche o cartão **Entendi**.
2. **Puxe** o prumo no canto direito da barra de menu para baixo.
3. Solte no tempo desejado. Quanto mais fundo, mais longo.
4. Digite um nome ou escolha **Sem nome**.
5. A contagem aparece ao lado do ícone. Clique no ícone para lista, cancelar e ajustes.

Atalhos enquanto puxa:

| Tecla | Efeito |
| --- | --- |
| `⌥` Option / Alt | Durações longas (horas) |
| `⇧` Shift | Precisão, sem encaixe em minutos redondos |
| `Esc` | Cancela o gesto |

Ajustes: idioma (PT/EN), contagem na barra, segundos, encaixe, som, notificações do sistema.

Os timers ficam só neste navegador (`localStorage`). Limpar dados do site apaga tudo. Não há conta nem servidor de dados pessoais.

### Desenvolvimento

Pilha: React 19, TanStack Start, Tailwind v4, Zustand. Código principal:

- `src/components/prumo/` — desktop, gesto, lista, avisos
- `src/lib/prumo/` — estado, mapeamento distância→tempo, i18n, som

Contribuições: [CONTRIBUTING.md](CONTRIBUTING.md). Conduta: [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md). Segurança: [SECURITY.md](SECURITY.md).

---

## English

### What it is

Prumo is a **web app** that simulates a macOS-style desktop so you can set timers with a gesture: drag the menu bar icon down. Distance is duration. You can name it. Remaining time shows in the bar. When it ends, you get a chime and an on-screen banner.

There is also a **native Xcode project** (real macOS menu bar) in [`native/macos/`](native/macos/). How to build the `.app`: [NATIVE.md](NATIVE.md).

This is **not** on the Mac App Store and **not** an Apple product. The native `.app` is **not** a prebuilt binary: you compile it in Xcode on your Mac.

### What it is not

- Not Gestimer or Gestimer 2.
- It does not use those products’ names, icons, copy, or artwork.
- It does not sync with Apple Reminders.
- It is not a medical, cooking-critical, childcare, transport, or legal-deadline alarm.

### Legal (please read)

Prumo is provided **as is**, **with no warranty**. Authors and the owner of this GitHub account are **not liable** for:

- lawsuits, claims, fines, or proceedings of any kind;
- misuse, unlawful use, or use outside the intended scope;
- damage to computers, peripherals, displays, audio, batteries, data, or systems;
- timers that fail to fire, fire late, are muted by the browser, or go unnoticed;
- loss of data in the browser `localStorage`.

You **assume all risk** and, to the fullest extent of the law, **release and indemnify** authors and contributors. Full text: [DISCLAIMER.md](DISCLAIMER.md). Third-party marks: [NOTICE.md](NOTICE.md).

This is **not** legal advice.

### Requirements

- [Node.js](https://nodejs.org/) **22** or newer
- npm 10+ (ships with Node)
- A current browser (Chrome, Firefox, Safari, Edge)
- Optional: allow site notifications in the browser

### Install and run

```bash
git clone https://github.com/amrbruno-art/prumo.git
cd prumo
npm install
npm run dev
```

Open the URL printed in the terminal (typically port **8080**).

```bash
npm run build
npm run typecheck
npm run preview
```

Do not run this as a safety-critical alarm.

### Native app (Mac `.app`)

Wrapping this site does **not** put an icon in the real menu bar. Native means Swift/AppKit.

Guide: **[NATIVE.md](NATIVE.md)**. Short version:

```bash
git clone https://github.com/amrbruno-art/prumo.git
open native/macos/Prumo.xcodeproj
```

In Xcode: pick your Team (Apple ID) → Product → Run. The plumb appears in the **menu bar** (not the Dock).

To install in `/Applications` **without the App Store** (`.dmg` / `.pkg`): **[INSTALL.md](INSTALL.md)**.

```bash
bash native/macos/scripts/package.sh
```

Or download the artifact from the [macOS installer workflow](https://github.com/amrbruno-art/prumo/actions/workflows/macos-installer.yml). Without notarization, use right-click → Open.

### Uninstall

Full guide: **[UNINSTALL.md](UNINSTALL.md)**. Short version:

1. Web: in the terminal, `Ctrl+C` / `Control+C` to stop `npm run dev`; delete the clone folder; clear the site’s data in the browser (`prumo-v1`).
2. Native: quit from the menu bar, delete `Prumo.app` from Applications and `~/Library/Application Support/Prumo`.
3. Node.js and Xcode are separate: uninstall them only if you installed them **solely** for Prumo.

### How to use

1. Optionally dismiss **Got it**.
2. **Pull** the plumb at the right of the menu bar downward.
3. Release at the time you want. Deeper is longer.
4. Type a name or choose **Untitled**.
5. Countdown sits next to the icon. Click the icon for the list, cancel, and settings.

While dragging:

| Key | Effect |
| --- | --- |
| `⌥` Option / Alt | Long durations (hours) |
| `⇧` Shift | Precision, no snap |
| `Esc` | Cancel the gesture |

Timers live only in this browser (`localStorage`). Clearing site data deletes them. There is no account and no personal-data server.

---

## License

[MIT](LICENSE) © 2026 Prumo contributors.

The MIT license already disclaims warranty and liability. [DISCLAIMER.md](DISCLAIMER.md) states the same in plain language. If any clause is unenforceable where you live, the rest still applies, and any remaining liability is capped at zero because the software is free.
