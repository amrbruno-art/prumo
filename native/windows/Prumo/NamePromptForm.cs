namespace Prumo;

sealed class NamePromptForm : Form
{
    public string TitleValue => _box.Text.Trim();
    public bool Confirmed { get; private set; }
    readonly TextBox _box;

    public NamePromptForm(string duration, string endClock, Lang lang)
    {
        Text = "Prumo";
        FormBorderStyle = FormBorderStyle.FixedDialog;
        StartPosition = FormStartPosition.CenterScreen;
        MaximizeBox = false;
        MinimizeBox = false;
        ShowInTaskbar = false;
        TopMost = true;
        ClientSize = new Size(300, 150);
        Font = new Font("Segoe UI", 9.75f);
        KeyPreview = true;
        KeyDown += (_, e) =>
        {
            if (e.KeyCode == Keys.Escape)
            {
                Confirmed = false;
                Close();
            }
        };

        var dur = new Label
        {
            Text = duration,
            Font = new Font("Segoe UI", 12, FontStyle.Bold),
            AutoSize = true,
            Location = new Point(16, 14),
        };
        var end = new Label
        {
            Text = endClock,
            ForeColor = Color.FromArgb(90, 90, 90),
            AutoSize = true,
            Location = new Point(16, 38),
        };
        var hint = new Label
        {
            Text = Copy.EscCancels(lang),
            AutoSize = true,
            Location = new Point(16, 58),
        };
        _box = new TextBox
        {
            PlaceholderText = Copy.NamePh(lang),
            Location = new Point(16, 80),
            Width = 268,
        };
        _box.KeyDown += (_, e) =>
        {
            if (e.KeyCode == Keys.Enter) { Confirm(true); e.SuppressKeyPress = true; }
            if (e.KeyCode == Keys.Escape) { Confirm(false); e.SuppressKeyPress = true; }
        };

        var cancel = new Button { Text = Copy.Cancel(lang), DialogResult = DialogResult.Cancel, Location = new Point(16, 112), Width = 80 };
        var skip = new Button { Text = Copy.Skip(lang), Location = new Point(110, 112), Width = 80 };
        var start = new Button { Text = Copy.Start(lang), Location = new Point(204, 112), Width = 80 };
        cancel.Click += (_, _) => Confirm(false);
        skip.Click += (_, _) => { _box.Text = ""; Confirm(true); };
        start.Click += (_, _) => Confirm(true);
        AcceptButton = start;
        CancelButton = cancel;

        Controls.AddRange(dur, end, hint, _box, cancel, skip, start);
        Shown += (_, _) => _box.Focus();
    }

    void Confirm(bool ok)
    {
        Confirmed = ok;
        DialogResult = ok ? DialogResult.OK : DialogResult.Cancel;
        Close();
    }
}
