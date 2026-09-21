# Desinstalar o Prumo / Uninstall Prumo

Prumo **não** instala um `.app` nativo no macOS, nem serviço de sistema, LaunchAgent, extensão de kernel ou item em `/Applications`. É um projeto Node que você clona e roda no navegador. Apagar a pasta e os dados do site basta.

Prumo does **not** install a native macOS `.app`, system service, LaunchAgent, kernel extension, or `/Applications` item. It is a cloned Node project that runs in the browser. Deleting the folder and the site data is enough.

**Sem garantia.** Ver [DISCLAIMER.md](DISCLAIMER.md).

---

## Português

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

## English

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
