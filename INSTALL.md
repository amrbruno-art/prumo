# Instalação paralela (fora da App Store) / Sideload

O Prumo **não** está na Mac App Store. Dá para instalar **à parte**, como qualquer app independente: um `.dmg` (arrastar para Aplicativos) ou um `.pkg` (instalador do macOS).

Prumo is **not** on the Mac App Store. You can **sideload** it like other indie Mac apps: a `.dmg` (drag to Applications) or a `.pkg` (macOS Installer).

**Sem garantia.** [DISCLAIMER.md](DISCLAIMER.md). Isto não é aconselhamento da Apple.

O binário **não** é gerado neste README: um Mac com Xcode (o seu, ou o runner do GitHub Actions) é que compila.

---

## Português

### O que você baixa

| Arquivo | Para que serve |
| --- | --- |
| `Prumo-x.y.z.dmg` | Abre uma janela: arraste `Prumo.app` para **Aplicativos** |
| `Prumo-x.y.z.pkg` | Duplo clique → Instalador do macOS → põe em `/Applications` |
| `Prumo-x.y.z.zip` | Só o `.app`, se você não quiser disco nem pacote |

Tudo isso é **distribuição direta** / **instalação paralela**. Não passa pela App Store, não precisa de TestFlight.

### 1. Pegar o pacote

**A) Já compilado (GitHub Actions)**

1. Abra [Actions → macOS installer](https://github.com/amrbruno-art/prumo/actions/workflows/macos-installer.yml).
2. Entre na execução verde mais recente.
3. Em **Artifacts**, baixe `Prumo-macos-installer`.
4. Descompacte o zip do artifact.

Quando houver uma tag `v1.0.0`, os mesmos arquivos vão para [Releases](https://github.com/amrbruno-art/prumo/releases).

**B) Compilar o instalador no seu Mac**

```bash
git clone https://github.com/amrbruno-art/prumo.git
cd prumo
bash native/macos/scripts/package.sh
open dist/macos
```

Gera `dist/macos/Prumo-1.0.0.dmg` e `Prumo-1.0.0.pkg`.

### 2. Instalar

**Imagem de disco (.dmg)**  
Abra o `.dmg` → arraste **Prumo** para **Applications** → ejetar o disco → abra `/Applications/Prumo.app`.

**Pacote (.pkg)**  
Duplo clique → continuar → a senha de administrador pode ser pedida → Instalar. O app vai para `/Applications`.

O ícone aparece na **barra de menu**, não no Dock.

### Como usar (gesto)

Clique **e segure** **Prumo** na barra e puxe para baixo. Só clicar abre o painel.

| Tecla | Efeito |
| --- | --- |
| (nenhuma) | Minutos |
| `⇧` Shift | Minutos precisos, sem encaixe |
| `⌥` Option | Horas |
| `Esc` | Cancela |

Isto também está em Ajustes e em Sobre, dentro do extra.

### 3. Se o Mac recusar (“desenvolvedor não identificado”)

Pacotes **sem notarização** (sem conta Apple Developer paga) são bloqueados pelo Gatekeeper. Isso é esperado.

1. Finder → Aplicativos → `Prumo.app`
2. Clique com o **botão direito** → **Abrir** → **Abrir**
3. Ou: Ajustes do Sistema → Privacidade e segurança → **Abrir mesmo assim**

Não desligue o SIP nem o Gatekeeper por causa disto.

### 4. Assinar e notarizar (opcional, para outras pessoas)

Para o instalador abrir sem o aviso, no Mac da conta **Apple Developer paga** (Developer ID):

Segredos do repositório (GitHub → Settings → Secrets):

- `MACOS_DEVELOPMENT_TEAM`
- `MACOS_CODE_SIGN_IDENTITY` (ex. `Developer ID Application: Nome (TEAMID)`)
- `MACOS_INSTALLER_SIGN_IDENTITY` (ex. `Developer ID Installer: Nome (TEAMID)`)
- `APPLE_ID`, `APPLE_APP_PASSWORD`, `APPLE_TEAM_ID`

O [workflow](.github/workflows/macos-installer.yml) usa isso se existir. Sem esses segredos, o pacote sai **ad-hoc** (só o seu Mac / “Abrir” no Finder).

Não precisa da App Store para isso. É o mesmo modelo de apps como o Homebrew Cask: download + Gatekeeper.

### 5. Abrir no login

Ajustes do Sistema → Geral → Itens de início → **+** → Prumo.

### 6. Instalei e não aparece na barra

Isto é um app **acessório**: **não vai para o Dock**. **Forçar Encerrar também não lista** este tipo de app — isso é normal. Use o Monitor de Atividade.

1. Instalar **não** abre o app. Finder → Aplicativos → dê **duplo clique** em Prumo.
2. Olhe à **direita** da barra de menu, junto do relógio. Deve aparecer o texto **Prumo**.
3. Monitor de Atividade → busque `Prumo`. Se não listar, o app não está rodando (volte ao passo 1; botão direito → Abrir se o Gatekeeper bloquear).
4. Mac com entalhe: extras escondidos ficam num **«**. Segure **⌘ Command** e arraste ícones da barra.
5. Ajustes do Sistema → Central de Controle (ou Itens de início e extensões) → permita extras na barra de menu.
6. Confirme o último arranque: `~/Library/Application Support/Prumo/last-launch.txt`

Para **sair**: clique em Prumo na barra → **Sair**. Não use Forçar Encerrar.

### Desinstalar

[UNINSTALL.md](UNINSTALL.md) (app nativo). Se usou o `.pkg`:

```bash
sudo pkgutil --forget art.amrbruno.prumo
```

(isso só apaga o recibo do instalador; o `.app` você remove como no guia.)

---

## English

### What you download

| File | What it is |
| --- | --- |
| `Prumo-x.y.z.dmg` | Drag `Prumo.app` to **Applications** |
| `Prumo-x.y.z.pkg` | Double-click → macOS Installer → `/Applications` |
| `Prumo-x.y.z.zip` | The `.app` only |

This is **direct distribution** / **sideload**. Not App Store, not TestFlight.

### Get the package

From [Actions → macOS installer](https://github.com/amrbruno-art/prumo/actions/workflows/macos-installer.yml) (artifact `Prumo-macos-installer`), or from [Releases](https://github.com/amrbruno-art/prumo/releases) on tags, or build on your Mac:

```bash
bash native/macos/scripts/package.sh
open dist/macos
```

### How to use (gesture)

Click **and hold** **Prumo** in the bar, then pull down. A plain click opens the panel.

| Key | Effect |
| --- | --- |
| (none) | Minutes |
| `⇧` Shift | Exact minutes, no snap |
| `⌥` Option | Hours |
| `Esc` | Cancel |

Also listed in Settings and About inside the extra.

### Gatekeeper

Unsigned / unnotarized builds need **right-click → Open**. Do not turn off SIP.

Notarized Developer ID builds (paid Apple Developer program, repo secrets) open without that prompt. Still not App Store.

### Login item

System Settings → General → Login Items → **+** → Prumo.

### Installed but nothing in the menu bar

This is an **accessory** app: **no Dock icon**. **Force Quit also hides this kind of app** — that is normal. Use Activity Monitor.

1. Installing does **not** launch it. Finder → Applications → **double-click** Prumo.
2. Look at the **right** of the menu bar, by the clock. You should see **Prumo**.
3. Activity Monitor → search `Prumo`. If it is missing, the app is not running.
4. Notch Macs hide extras behind **«**. Hold **⌘** and drag extras to make room.
5. System Settings → Control Center / Login Items & Extensions → allow menu bar extras.
6. Launch breadcrumb: `~/Library/Application Support/Prumo/last-launch.txt`

To **quit**: click Prumo in the bar → **Quit**. Do not rely on Force Quit.

### Uninstall

[UNINSTALL.md](UNINSTALL.md). After a `.pkg`: `sudo pkgutil --forget art.amrbruno.prumo`
