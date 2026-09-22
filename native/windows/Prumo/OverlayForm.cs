namespace Prumo;

sealed class OverlayForm : Form
{
    Point _start;
    Point _bob;
    string _label = "";
    string _end = "";

    public OverlayForm()
    {
        FormBorderStyle = FormBorderStyle.None;
        ShowInTaskbar = false;
        TopMost = true;
        StartPosition = FormStartPosition.Manual;
        BackColor = Color.Magenta;
        TransparencyKey = Color.Magenta;
        DoubleBuffered = true;
        Bounds = Screen.PrimaryScreen?.Bounds ?? new Rectangle(0, 0, 800, 600);
    }

    protected override bool ShowWithoutActivation => true;
    protected override CreateParams CreateParams
    {
        get
        {
            var cp = base.CreateParams;
            cp.ExStyle |= 0x80 | 0x20; // WS_EX_TOOLWINDOW | WS_EX_TRANSPARENT
            return cp;
        }
    }

    public void UpdatePull(Point start, Point bob, string label, string end)
    {
        var screen = Screen.FromPoint(bob);
        if (Bounds != screen.Bounds) Bounds = screen.Bounds;
        _start = PointToClient(start);
        _bob = PointToClient(bob);
        _label = label;
        _end = end;
        if (!Visible) Show();
        Invalidate();
    }

    protected override void OnPaint(PaintEventArgs e)
    {
        var g = e.Graphics;
        g.SmoothingMode = System.Drawing.Drawing2D.SmoothingMode.AntiAlias;
        using var ghost = new Pen(Color.FromArgb(55, 255, 255, 255), 1) { DashPattern = [3, 4] };
        g.DrawLine(ghost, _start, new Point(_start.X, _bob.Y));
        using var cord = new Pen(Color.FromArgb(200, 196, 115, 56), 2);
        g.DrawLine(cord, _start, _bob);

        var dx = _bob.X - _start.X;
        var dy = _bob.Y - _start.Y;
        var len = Math.Max(1f, (float)Math.Sqrt(dx * dx + dy * dy));
        var ux = dx / len;
        var uy = dy / len;
        var bx = -uy;
        var by = ux;
        var baseX = _bob.X - ux * 16;
        var baseY = _bob.Y - uy * 16;
        var cone = new[]
        {
            _bob,
            new Point((int)(baseX + bx * 8), (int)(baseY + by * 8)),
            new Point((int)(baseX - bx * 8), (int)(baseY - by * 8)),
        };
        using var fill = new SolidBrush(Color.FromArgb(30, 33, 38));
        using var edge = new Pen(Color.FromArgb(200, 196, 115, 56), 2);
        g.FillPolygon(fill, cone);
        g.DrawPolygon(edge, cone);

        using var durFont = new Font("Segoe UI", 20, FontStyle.Bold, GraphicsUnit.Pixel);
        using var endFont = new Font("Segoe UI", 13, FontStyle.Regular, GraphicsUnit.Pixel);
        var durSize = g.MeasureString(_label, durFont);
        var endSize = g.MeasureString(_end, endFont);
        const int pad = 12;
        const int gap = 8;
        var hud = new RectangleF(
            _bob.X + 18,
            _bob.Y - (Math.Max(durSize.Height, endSize.Height) + 16) / 2,
            durSize.Width + gap + endSize.Width + pad * 2,
            Math.Max(durSize.Height, endSize.Height) + 16);
        using var hudBg = new SolidBrush(Color.FromArgb(184, 0, 0, 0));
        g.FillRounded(hud, 10, hudBg);
        g.DrawString(_label, durFont, Brushes.White, hud.X + pad, hud.Y + (hud.Height - durSize.Height) / 2);
        using var muted = new SolidBrush(Color.FromArgb(184, 255, 255, 255));
        g.DrawString(_end, endFont, muted, hud.X + pad + durSize.Width + gap, hud.Y + (hud.Height - endSize.Height) / 2);
    }
}

static class Gdi
{
    public static void FillRounded(this Graphics g, RectangleF r, float radius, Brush brush)
    {
        using var path = new System.Drawing.Drawing2D.GraphicsPath();
        var d = radius * 2;
        path.AddArc(r.X, r.Y, d, d, 180, 90);
        path.AddArc(r.Right - d, r.Y, d, d, 270, 90);
        path.AddArc(r.Right - d, r.Bottom - d, d, d, 0, 90);
        path.AddArc(r.X, r.Bottom - d, d, d, 90, 90);
        path.CloseFigure();
        g.FillPath(brush, path);
    }
}
