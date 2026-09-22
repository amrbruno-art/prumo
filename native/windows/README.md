# Prumo for Windows

System-tray timer (the Windows equivalent of a macOS menu extra). **Not Gestimer.** MIT, AS IS, no warranty.

There is no menu bar on Windows. Prumo lives in the **notification area** (tray), usually at the bottom-right of the taskbar. Pull the plumb **toward the screen** (up, if the taskbar is at the bottom).

## Build

Needs [.NET 8 SDK](https://dotnet.microsoft.com/download) on Windows.

```bat
cd native\windows
dotnet publish Prumo\Prumo.csproj -c Release -r win-x64 --self-contained true -p:PublishSingleFile=true -o ..\..\dist\windows
```

Run `dist\windows\Prumo.exe`. Copy the folder anywhere; there is no installer required.

GitHub Actions workflow **Windows zip** publishes `Prumo-windows.zip` on each push to `native/windows/`.

## Use

1. After launch, look in the tray (you may need **Show hidden icons** ^).
2. **Click** — panel (presets, list, settings, Quit).
3. **Click and hold**, then pull toward the desktop — duration + end clock.
4. Release; name it or Esc to cancel.
5. Alt = hours. Shift = exact minutes.

No taskbar button. To quit: tray → Prumo → **Sair** / **Quit**, or the panel.

## Uninstall

Quit Prumo. Delete `Prumo.exe` (and its folder). Delete `%AppData%\Prumo`.

## SmartScreen

Unsigned sideload: Windows may say “Windows protected your PC”. More info → Run anyway. Do not disable SmartScreen globally.
