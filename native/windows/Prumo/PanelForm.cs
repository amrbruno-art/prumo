namespace Prumo;

sealed class PanelForm : Form
{
    readonly Store _store;
    readonly Action _onQuit;
    FlowLayoutPanel _list = null!;
    ComboBox _lang = null!;
    CheckBox _countdown = null!, _seconds = null!, _snap = null!, _sound = null!, _notify = null!;
    bool _syncing;

    public PanelForm(Store store, Action onQuit)
    {
        _store = store;
        _onQuit = onQuit;
        Text = "Prumo";
        FormBorderStyle = FormBorderStyle.FixedToolWindow;
        StartPosition = FormStartPosition.Manual;
        ShowInTaskbar = false;
        TopMost = true;
        ClientSize = new Size(300, 460);
        Font = new Font("Segoe UI", 9.5f);
        BackColor = Color.FromArgb(243, 239, 232);
        KeyPreview = true;
        KeyDown += (_, e) => { if (e.KeyCode == Keys.Escape) Hide(); };
        Build();
        _store.Changed += () => { if (IsHandleCreated) BeginInvoke(RefreshList); };
        PlaceNearTray();
    }

    void PlaceNearTray()
    {
        var s = Screen.PrimaryScreen ?? Screen.AllScreens[0];
        var wa = s.WorkingArea;
        Location = Taskbar.Edge() switch
        {
            TaskbarEdge.Bottom => new Point(wa.Right - Width - 12, wa.Bottom - Height - 8),
            TaskbarEdge.Top => new Point(wa.Right - Width - 12, wa.Top + 8),
            TaskbarEdge.Right => new Point(wa.Right - Width - 8, wa.Bottom - Height - 12),
            _ => new Point(wa.Left + 8, wa.Bottom - Height - 12),
        };
    }

    void Build()
    {
        var header = new Label { Text = "Prumo", Font = new Font("Segoe UI", 12, FontStyle.Bold), Location = new Point(14, 10), AutoSize = true };
        var about = new Label
        {
            Text = "MIT · AS IS. Não é o Gestimer.\nClique e segure na bandeja e puxe para a tela.\n⇧ minutos precisos · Alt horas · Esc cancela.",
            Location = new Point(14, 36),
            Size = new Size(272, 52),
        };
        var quick = new Label { Text = Copy.Quick(_store.Settings.Language), Location = new Point(14, 92), AutoSize = true };
        var presets = new FlowLayoutPanel { Location = new Point(10, 112), Size = new Size(280, 36), WrapContents = false };
        foreach (var m in new[] { 1, 3, 5, 10, 15, 25, 45 })
        {
            var minutes = m;
            var b = new Button { Text = $"{m}m", Width = 36, Height = 28 };
            b.Click += (_, _) => _store.AddTimer("", minutes * 60_000);
            presets.Controls.Add(b);
        }

        _list = new FlowLayoutPanel
        {
            Location = new Point(10, 152),
            Size = new Size(280, 140),
            AutoScroll = true,
            FlowDirection = FlowDirection.TopDown,
            WrapContents = false,
        };

        _lang = new ComboBox { DropDownStyle = ComboBoxStyle.DropDownList, Location = new Point(14, 300), Width = 120 };
        _lang.Items.Add("Português");
        _lang.Items.Add("English");
        _lang.SelectedIndexChanged += (_, _) =>
        {
            if (_syncing) return;
            _store.Patch(s => s.Language = _lang.SelectedIndex == 0 ? Lang.Pt : Lang.En);
        };
        _countdown = Check("Contagem na bandeja", 328, s => s.ShowCountdown = _countdown.Checked);
        _seconds = Check("Segundos", 352, s => s.ShowSeconds = _seconds.Checked);
        _snap = Check("Encaixar minutos", 376, s => s.Snap = _snap.Checked);
        _sound = Check("Som", 400, s => s.Sound = _sound.Checked);
        _notify = Check("Notificações", 424, s => s.Notifications = _notify.Checked);

        var quit = new Button { Text = Copy.Quit(_store.Settings.Language), Location = new Point(190, 296), Width = 96 };
        quit.Click += (_, _) => _onQuit();

        Controls.AddRange(new Control[] { header, about, quick, presets, _list, _lang, _countdown, _seconds, _snap, _sound, _notify, quit });
        SyncChecks();
        RefreshList();
    }

    CheckBox Check(string label, int y, Action<AppSettings> patch)
    {
        var box = new CheckBox { Text = label, Location = new Point(14, y), AutoSize = true };
        box.CheckedChanged += (_, _) => { if (!_syncing) _store.Patch(patch); };
        return box;
    }

    void SyncChecks()
    {
        _syncing = true;
        _lang.SelectedIndex = _store.Settings.Language == Lang.Pt ? 0 : 1;
        _countdown.Checked = _store.Settings.ShowCountdown;
        _seconds.Checked = _store.Settings.ShowSeconds;
        _snap.Checked = _store.Settings.Snap;
        _sound.Checked = _store.Settings.Sound;
        _notify.Checked = _store.Settings.Notifications;
        _syncing = false;
    }

    void RefreshList()
    {
        _list.Controls.Clear();
        var running = _store.Timers.Where(t => t.Status == TimerStatus.Running).ToList();
        if (running.Count == 0)
        {
            _list.Controls.Add(new Label { Text = Copy.Empty(_store.Settings.Language), AutoSize = true, MaximumSize = new Size(260, 0) });
            return;
        }
        var now = DateTimeOffset.UtcNow.ToUnixTimeMilliseconds();
        foreach (var t in running)
        {
            var id = t.Id;
            var row = new FlowLayoutPanel { Width = 256, Height = 28, WrapContents = false };
            var left = Math.Max(0, t.EndsAt - now);
            var name = string.IsNullOrEmpty(t.Title) ? Copy.Untitled(_store.Settings.Language) : t.Title;
            row.Controls.Add(new Label
            {
                Text = $"{name}  {Format.Remaining((int)left, _store.Settings.ShowSeconds)}",
                AutoSize = true,
                Width = 180,
            });
            var cancel = new Button { Text = "×", Width = 28, Height = 24 };
            cancel.Click += (_, _) => _store.Cancel(id);
            row.Controls.Add(cancel);
            _list.Controls.Add(row);
        }
    }

    protected override void OnShown(EventArgs e)
    {
        base.OnShown(e);
        PlaceNearTray();
        SyncChecks();
        RefreshList();
    }

    protected override void OnDeactivate(EventArgs e)
    {
        base.OnDeactivate(e);
        Hide();
    }
}
