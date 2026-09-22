# Prumo no Windows

O equivalente da barra de menu do Mac é a **bandeja do sistema** (área de notificação), em geral no canto inferior direito.

Prumo for Windows is a **system-tray** app. There is no macOS-style menu bar.

**Não está na Microsoft Store.** Distribuição direta / sideload. MIT. **Sem garantia.** [DISCLAIMER.md](DISCLAIMER.md)

## Instalar

1. Baixe [Prumo-windows-*.zip](https://github.com/amrbruno-art/prumo/releases) (release **v1.0.9+**, ou o artifact **Prumo-windows-zip** em Actions).
2. Extraia a pasta (por exemplo em `Downloads\Prumo`).
3. Dê um duplo clique em `Prumo.exe`.
4. Olhe a bandeja (seta ^ se o ícone estiver oculto). Não aparece um botão na barra de tarefas.

Se o SmartScreen disser que o Windows protegeu o PC: **Mais informações** → **Executar assim mesmo**.

## Usar

| Gesto | Efeito |
| --- | --- |
| Clique | Painel (tempos rápidos, lista, ajustes, **Sair**) |
| Clique **e segure**, puxe **para a tela** | Escolhe a duração. HUD: `10 min` e `10:10` |
| `Alt` | Horas |
| `Shift` | Minutos precisos |
| `Esc` | Cancela o puxão ou o nome |

Se a barra de tarefas está **em baixo**, puxe **para cima**. Em cima, puxe para baixo.

## Compilar no seu PC

Windows + [.NET 8 SDK](https://dotnet.microsoft.com/download):

```bat
git clone https://github.com/amrbruno-art/prumo.git
cd prumo\native\windows
dotnet publish Prumo\Prumo.csproj -c Release -r win-x64 --self-contained true -p:PublishSingleFile=true -o ..\..\dist\windows
```

Detalhes: [native/windows/README.md](native/windows/README.md)

## Desinstalar

1. Clique no Prumo na bandeja → **Sair** (ou Gerenciador de Tarefas → finalizar `Prumo`).
2. Apague a pasta do `Prumo.exe`.
3. Apague `%AppData%\Prumo`.

Não há serviço nem chave obrigatória no registro.
