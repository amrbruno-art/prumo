using System.Runtime.InteropServices;

namespace Prumo;

static class Program
{
    [STAThread]
    static void Main()
    {
        ApplicationConfiguration.Initialize();
        Application.Run(new PrumoContext());
    }
}

sealed class PrumoContext : ApplicationContext
{
    readonly Store _store = new();
    readonly NotifyIcon _tray;
    readonly OverlayForm _overlay = new();
    readonly PanelForm _panel;
    readonly System.Windows.Forms.Timer _poll = new() { Interval = 16 };

    bool _tracking;
    bool _activated;
    Point _origin;

    public PrumoContext()
    {
        _store.Load();
        _store.OnFire = OnFire;
        _store.StartTicking();
        _panel = new PanelForm(_store, Quit);

        var menu = new ContextMenuStrip();
        menu.Items.Add(Copy.Open(_store.Settings.Language), null, (_, _) => ShowPanel());
        menu.Items.Add(Copy.Quit(_store.Settings.Language), null, (_, _) => Quit());

        _tray = new NotifyIcon
        {
            Icon = LoadIcon(),
            Visible = true,
            Text = "Prumo",
            ContextMenuStrip = menu,
        };
        _tray.MouseDown += OnTrayMouseDown;
        _store.Changed += RefreshTip;
        _poll.Tick += (_, _) => PollDrag();
        RefreshTip();
        WriteBreadcrumb();
    }

    static Icon LoadIcon()
    {
        var ico = Path.Combine(System.AppContext.BaseDirectory, "prumo.ico");
        if (File.Exists(ico)) return new Icon(ico, 16, 16);
        return SystemIcons.Application;
    }

    void OnTrayMouseDown(object? sender, MouseEventArgs e)
    {
        if (e.Button != MouseButtons.Left) return;
        _panel.Hide();
        _tracking = true;
        _activated = false;
        _origin = Cursor.Position;
        _poll.Start();
    }

    void PollDrag()
    {
        if (!_tracking) return;
        if ((GetAsyncKeyState(0x1B) & 0x8000) != 0)
        {
            CancelPull();
            return;
        }
        if ((Control.MouseButtons & MouseButtons.Left) == 0)
        {
            EndPull();
            return;
        }

        var now = Cursor.Position;
        var dy = Taskbar.PullDistance(_origin, now);
        var alt = Control.ModifierKeys.HasFlag(Keys.Alt);
        var shift = Control.ModifierKeys.HasFlag(Keys.Shift);
        if (!_activated)
        {
            if (dy >= Mapping.ActivatePx) _activated = true;
            else return;
        }
        var raw = Mapping.DragToMinutes(dy, Taskbar.ViewportSpan(), alt);
        var minutes = Mapping.Snap(raw, _store.Settings.Snap, shift);
        var ms = Mapping.MinutesToMs(minutes);
        _overlay.UpdatePull(_origin, now, Format.Duration(ms, _store.Settings.Language), Format.EndClock(ms, _store.Settings.Language));
    }

    void EndPull()
    {
        _poll.Stop();
        _tracking = false;
        var now = Cursor.Position;
        var dy = Taskbar.PullDistance(_origin, now);
        var was = _activated;
        _overlay.Hide();
        _activated = false;
        if (!was || dy < Mapping.ActivatePx)
        {
            ShowPanel();
            return;
        }
        var alt = Control.ModifierKeys.HasFlag(Keys.Alt);
        var shift = Control.ModifierKeys.HasFlag(Keys.Shift);
        var raw = Mapping.DragToMinutes(dy, Taskbar.ViewportSpan(), alt);
        var minutes = Mapping.Snap(raw, _store.Settings.Snap, shift);
        var ms = Mapping.MinutesToMs(minutes);
        if (ms < 15_000) return;
        PromptName(ms);
    }

    void CancelPull()
    {
        _poll.Stop();
        _tracking = false;
        _activated = false;
        _overlay.Hide();
    }

    void PromptName(int ms)
    {
        using var dlg = new NamePromptForm(
            Format.Duration(ms, _store.Settings.Language),
            Format.EndClock(ms, _store.Settings.Language),
            _store.Settings.Language);
        var result = dlg.ShowDialog();
        if (result == DialogResult.OK && dlg.Confirmed)
            _store.AddTimer(dlg.TitleValue, ms);
    }

    void ShowPanel()
    {
        if (_panel.Visible)
        {
            _panel.Activate();
            return;
        }
        _panel.Show();
        _panel.Activate();
    }

    void OnFire(PrumoTimer timer)
    {
        var lang = _store.Settings.Language;
        var title = string.IsNullOrEmpty(timer.Title) ? Copy.Untitled(lang) : timer.Title;
        if (_store.Settings.Sound) System.Media.SystemSounds.Asterisk.Play();
        if (_store.Settings.Notifications)
        {
            _tray.BalloonTipTitle = "Prumo";
            _tray.BalloonTipText = $"{title} — {Copy.Fired(lang)}";
            _tray.ShowBalloonTip(5000);
        }
    }

    void RefreshTip()
    {
        var next = _store.NextRunning;
        if (_store.Settings.ShowCountdown && next is not null)
        {
            var left = Math.Max(0, next.EndsAt - DateTimeOffset.UtcNow.ToUnixTimeMilliseconds());
            var text = "Prumo " + Format.Remaining((int)left, _store.Settings.ShowSeconds);
            _tray.Text = text.Length <= 63 ? text : text[..63];
        }
        else _tray.Text = "Prumo";
    }

    void Quit()
    {
        _store.Save();
        _tray.Visible = false;
        _tray.Dispose();
        _overlay.Dispose();
        _panel.Dispose();
        ExitThread();
    }

    static void WriteBreadcrumb()
    {
        try
        {
            var dir = Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.ApplicationData), "Prumo");
            Directory.CreateDirectory(dir);
            File.WriteAllText(Path.Combine(dir, "last-launch.txt"), DateTime.Now.ToString("o") + " launched\n");
        }
        catch { /* ignore */ }
    }

    [DllImport("user32.dll")]
    static extern short GetAsyncKeyState(int vKey);
}
