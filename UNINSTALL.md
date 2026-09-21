# Desinstalar o Prumo / Uninstall Prumo

Há duas formas: a **simulação web** (clone Node) e, se você compilou, o **`.app` nativo**.

There are two forms: the **web simulation** (Node clone) and, if you built it, the **native `.app`**.

**Sem garantia.** Ver [DISCLAIMER.md](DISCLAIMER.md).

---

## App nativo (`.app`) — Português

Só vale se você gerou o app no Xcode ([NATIVE.md](NATIVE.md)).

1. **Encerrar.** Clique no prumo na barra de menu → **Encerrar Prumo**. Ou Activity Monitor → Prumo → Sair.
2. **Tirar de Aplicativos.**
   - Finder → Aplicativos → `Prumo.app` → Lixo, depois esvazie.
   - Ou: `rm -rf /Applications/Prumo.app`
3. **Dados do app.**
   ```bash
   rm -rf ~/Library/Application\ Support/Prumo
   rm -f ~/Library/Preferences/art.amrbruno.prumo.plist
   rm -rf ~/Library/Caches/art.amrbruno.prumo
   ```
4. **Início automático.** Ajustes do Sistema → Geral → Itens de início → remova Prumo se estiver lá.
5. **Notificações.** Ajustes do Sistema → Notificações → Prumo → desligar ou remover.
6. **Recibo do .pkg** (só se instalou pelo pacote):
   ```bash
   sudo pkgutil --forget art.amrbruno.prumo
   ```
7. **Xcode / clone.** Se não quiser mais o código: apague a pasta do repositório. O Xcode em si não é o Prumo; não desinstale o Xcode só por isso.

Isto **não** remove o Node, o Git nem outros programas.

---

## App nativo (`.app`) — English

Only if you built the app in Xcode ([NATIVE.md](NATIVE.md)).

1. **Quit.** Click the plumb in the menu bar → **Quit Prumo**. Or Activity Monitor → Prumo → Quit.
2. **Remove from Applications.**
   - Finder → Applications → `Prumo.app` → Trash, then empty.
   - Or: `rm -rf /Applications/Prumo.app`
3. **App data.**
   ```bash
   rm -rf ~/Library/Application\ Support/Prumo
   rm -f ~/Library/Preferences/art.amrbruno.prumo.plist
   rm -rf ~/Library/Caches/art.amrbruno.prumo
   ```
4. **Login item.** System Settings → General → Login Items → remove Prumo if listed.
5. **Notifications.** System Settings → Notifications → Prumo → turn off or remove.
6. **`.pkg` receipt** (only if you used the installer package):
   ```bash
   sudo pkgutil --forget art.amrbruno.prumo
   ```
7. **Xcode / clone.** Delete the repo folder if you no longer want the source. Do not uninstall Xcode just for this.

This does **not** remove Node, Git, or other programs.

---

## Simulação web — Português

A web **não** instala um `.app`, nem LaunchAgent, nem item em `/Applications`. Apagar a pasta e os dados do site basta.

### 1. Parar o programa

No terminal onde rodou `npm run dev` ou `npm run preview`:

- `Ctrl+C` (Windows/Linux) ou `Control+C` (Mac)

Se ainda houver um Node preso a isso:

```bash
# na pasta do projeto
npm run preview:stop
```

Ou feche o Terminal / iTerm.

### 2. Apagar os arquivos

Saia da pasta do projeto e remova o clone:

```bash
cd ~
rm -rf prumo
```

Se clonou noutro sítio, apague **essa** pasta (incluindo `node_modules`). No Finder: arraste a pasta para o Lixo e esvazie.

Isto remove código, dependências e o build. Não mexe no resto do Mac.

### 3. Apagar timers e ajustes do navegador

Os dados ficam só neste browser, na chave `prumo-v1` do `localStorage`.

**Safari (Mac)**  
Safari → Ajustes → Privacidade → Gerir dados de sites → procure o endereço que você usou (por exemplo `localhost`) → Remover.

**Chrome**  
chrome://settings/content/all → o mesmo endereço → Lixo.

**Firefox**  
Ajustes → Privacidade → Cookies e dados → Gerir dados → remova o site.

**Edge**  
edge://settings/content/all → remova o site.

Ou, na página do Prumo, abra as Ferramentas de desenvolvedor → Application/Armazenamento → Local Storage → apague `prumo-v1`.

### 4. Notificações

Se autorizou avisos:

- Safari: Ajustes → Sites → Notificações → recusar ou remover o site  
- Chrome: chrome://settings/content/notifications  
- Firefox: Ajustes → Privacidade → Permissões → Notificações  

### 5. Atalho / PWA (só se instalou na Dock ou na mesa)

Se o navegador ofereceu “Instalar” / “Adicionar à mesa”:

- **Mac:** clique com o botão direito no ícone na Dock → Opções → Remover da Dock; apague o ícone na mesa se existir.  
- **Chrome:** `chrome://apps` → remova Prumo.  
- **iPhone/iPad:** mantenha o ícone na tela de início → Remover app.

### 6. Node.js (opcional)

O Node **não** é o Prumo. Só desinstale o Node se você o instalou **apenas** para este projeto e não precisa dele para mais nada.

- Site oficial: [https://nodejs.org](https://nodejs.org)  
- Homebrew: `brew uninstall node` (isto afeta outros projetos)

Não desinstale o Node se usa outros programas JavaScript.

### Conferir que saiu

- A pasta do clone não existe.  
- Abrir o endereço antigo no navegador não carrega o Prumo.  
- Não há `prumo-v1` no armazenamento do site.  
- Não há ícone na Dock / tela de início.

---

## Simulação web — English

The web app does **not** install a native `.app`, LaunchAgent, or `/Applications` item. Deleting the folder and the site data is enough.

### 1. Stop the program

In the terminal where `npm run dev` or `npm run preview` is running:

- `Ctrl+C` (Windows/Linux) or `Control+C` (Mac)

If a Node process is still serving the built preview:

```bash
# from the project folder
npm run preview:stop
```

Or quit Terminal / iTerm.

### 2. Delete the files

Leave the project folder and remove the clone:

```bash
cd ~
rm -rf prumo
```

If you cloned somewhere else, delete **that** folder (including `node_modules`). In Finder: move the folder to Trash and empty it.

This removes source, dependencies, and build output. It does not change the rest of the Mac.

### 3. Delete timers and settings from the browser

Data lives only in this browser, under the `localStorage` key `prumo-v1`.

**Safari (Mac)**  
Safari → Settings → Privacy → Manage Website Data → find the address you used (for example `localhost`) → Remove.

**Chrome**  
chrome://settings/content/all → that origin → trash.

**Firefox**  
Settings → Privacy → Cookies and site data → Manage data → remove the site.

**Edge**  
edge://settings/content/all → remove the site.

Or, on the Prumo page: Developer Tools → Application/Storage → Local Storage → delete `prumo-v1`.

### 4. Notifications

If you allowed alerts:

- Safari: Settings → Websites → Notifications → deny or remove the site  
- Chrome: chrome://settings/content/notifications  
- Firefox: Settings → Privacy → Permissions → Notifications  

### 5. Shortcut / PWA (only if you installed it)

If the browser offered “Install” / “Add to Dock” / “Add to Home Screen”:

- **Mac:** Control-click the Dock icon → Options → Remove from Dock; delete any Desktop icon.  
- **Chrome:** `chrome://apps` → remove Prumo.  
- **iPhone/iPad:** press and hold the Home Screen icon → Remove App.

### 6. Node.js (optional)

Node is **not** Prumo. Uninstall Node only if you installed it **solely** for this project.

- Official: [https://nodejs.org](https://nodejs.org)  
- Homebrew: `brew uninstall node` (this affects other projects)

Do not uninstall Node if you use other JavaScript tools.

### Check that it is gone

- The clone folder is gone.  
- The old address does not load Prumo.  
- There is no `prumo-v1` in site storage.  
- There is no Dock / Home Screen icon.
