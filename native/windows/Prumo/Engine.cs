using System.Text.Json;
using System.Text.Json.Serialization;

namespace Prumo;

enum Lang { Pt, En }

enum TimerStatus { Running, Fired, Dismissed }

sealed class PrumoTimer
{
    public string Id { get; set; } = "";
    public string Title { get; set; } = "";
    public int DurationMs { get; set; }
    public long StartedAt { get; set; }
    public long EndsAt { get; set; }
    public TimerStatus Status { get; set; }
}

sealed class AppSettings
{
    public Lang Language { get; set; } = Lang.Pt;
    public bool ShowCountdown { get; set; } = true;
    public bool ShowSeconds { get; set; } = true;
    public bool Snap { get; set; } = true;
    public bool Sound { get; set; } = true;
    public bool Notifications { get; set; } = true;
    public bool SeenOnboarding { get; set; }
}

sealed class PersistedState
{
    public List<PrumoTimer> Timers { get; set; } = [];
    public AppSettings Settings { get; set; } = new();
}

static class Mapping
{
    public const float DragThresholdPx = 12;
    public const float ActivatePx = 24;

    static readonly (float t, double m)[] ShortStops =
    [
        (0, 0.5), (0.06, 1), (0.11, 2), (0.16, 3), (0.22, 5), (0.3, 8),
        (0.37, 10), (0.46, 15), (0.54, 20), (0.61, 25), (0.68, 30),
        (0.76, 45), (0.83, 60), (0.91, 120), (1, 480),
    ];

    static readonly (float t, double m)[] LongStops =
    [
        (0, 5), (0.1, 15), (0.2, 30), (0.32, 60), (0.44, 120),
        (0.56, 240), (0.68, 480), (0.82, 720), (1, 1440),
    ];

    static readonly double[] SnapMinutes =
    [
        0.5, 1, 2, 3, 4, 5, 6, 8, 10, 12, 15, 20, 25, 30, 35, 40, 45, 50, 55, 60,
        75, 90, 105, 120, 150, 180, 240, 300, 360, 480, 600, 720, 960, 1200, 1440,
    ];

    public static double DragToMinutes(float distancePx, float viewportH, bool stretch)
    {
        var usable = Math.Max(260, viewportH - 96);
        var t = Math.Clamp((distancePx - DragThresholdPx) / usable, 0, 1);
        return LerpStops(t, stretch ? LongStops : ShortStops);
    }

    public static double Snap(double raw, bool enabled, bool precise)
    {
        if (precise)
        {
            if (raw < 5) return Math.Round(raw * 2) / 2;
            return Math.Max(1, Math.Round(raw));
        }
        if (!enabled) return Math.Max(0.5, Math.Round(raw * 2) / 2);
        var best = SnapMinutes[0];
        var bestD = double.PositiveInfinity;
        foreach (var s in SnapMinutes)
        {
            var d = Math.Abs(s - raw);
            if (d < bestD) { best = s; bestD = d; }
        }
        return best;
    }

    public static int MinutesToMs(double minutes) => (int)Math.Round(minutes * 60_000);

    static double LerpStops(float t, (float t, double m)[] stops)
    {
        if (t <= 0) return stops[0].m;
        if (t >= 1) return stops[^1].m;
        for (var i = 1; i < stops.Length; i++)
        {
            var (r1, m1) = stops[i];
            var (r0, m0) = stops[i - 1];
            if (t <= r1)
            {
                var u = (t - r0) / (r1 - r0);
                return m0 + (m1 - m0) * u;
            }
        }
        return stops[^1].m;
    }
}

static class Format
{
    public static string Duration(int ms, Lang lang)
    {
        var totalSec = Math.Max(0, (int)Math.Round(ms / 1000.0));
        if (totalSec < 60) return lang == Lang.Pt ? $"{totalSec} s" : $"{totalSec}s";
        var totalMin = (int)Math.Round(totalSec / 60.0);
        var hours = totalMin / 60;
        var mins = totalMin % 60;
        if (hours == 0) return $"{mins} min";
        if (mins == 0) return lang == Lang.Pt ? $"{hours} h" : $"{hours}h";
        return lang == Lang.Pt ? $"{hours} h {mins} min" : $"{hours}h {mins}m";
    }

    public static string Remaining(int ms, bool showSeconds)
    {
        var totalSec = Math.Max(0, (int)Math.Ceiling(ms / 1000.0));
        string Pad(int n) => n.ToString("00");
        if (!showSeconds)
        {
            var roundedMin = Math.Max(1, (int)Math.Ceiling(totalSec / 60.0));
            if (roundedMin >= 60)
            {
                var h = roundedMin / 60;
                var m = roundedMin % 60;
                return m == 0 ? $"{h}h" : $"{h}h {Pad(m)}m";
            }
            return $"{roundedMin} min";
        }
        var hours = totalSec / 3600;
        var mins = (totalSec % 3600) / 60;
        var secs = totalSec % 60;
        if (hours > 0) return $"{hours}:{Pad(mins)}:{Pad(secs)}";
        return $"{Pad(mins)}:{Pad(secs)}";
    }

    public static string EndClock(int ms, Lang lang)
    {
        var date = DateTime.Now.AddMilliseconds(ms);
        var clock = date.ToString("HH:mm");
        if (date.Date == DateTime.Today) return clock;
        if (date.Date == DateTime.Today.AddDays(1))
            return lang == Lang.Pt ? $"amanhã {clock}" : $"tomorrow {clock}";
        return lang == Lang.Pt ? date.ToString("dd/MM HH:mm") : date.ToString("MMM d HH:mm");
    }
}

static class Copy
{
    public static string Untitled(Lang l) => l == Lang.Pt ? "Sem nome" : "Untitled";
    public static string Now(Lang l) => l == Lang.Pt ? "Agora" : "Now";
    public static string Settings(Lang l) => l == Lang.Pt ? "Ajustes" : "Settings";
    public static string About(Lang l) => l == Lang.Pt ? "Sobre" : "About";
    public static string Quit(Lang l) => l == Lang.Pt ? "Sair" : "Quit";
    public static string Cancel(Lang l) => l == Lang.Pt ? "Cancelar" : "Cancel";
    public static string Empty(Lang l) => l == Lang.Pt
        ? "Clique e segure o Prumo na bandeja, depois puxe para a tela."
        : "Click and hold Prumo in the tray, then pull toward the screen.";
    public static string Quick(Lang l) => l == Lang.Pt ? "Rápido" : "Quick";
    public static string HoldHint(Lang l) => l == Lang.Pt
        ? "Clique e segure na bandeja"
        : "Click and hold in the tray";
    public static string EscCancels(Lang l) => l == Lang.Pt
        ? "Esc cancela e não cria o timer."
        : "Esc cancels and does not start the timer.";
    public static string NamePh(Lang l) => l == Lang.Pt ? "Nome do timer" : "Timer name";
    public static string Skip(Lang l) => l == Lang.Pt ? "Sem nome" : "Untitled";
    public static string Start(Lang l) => l == Lang.Pt ? "Começar" : "Start";
    public static string Shortcuts(Lang l) => l == Lang.Pt ? "Enquanto puxa" : "While pulling";
    public static string Open(Lang l) => l == Lang.Pt ? "Abrir" : "Open";
    public static string Fired(Lang l) => l == Lang.Pt ? "Tempo esgotado." : "Time is up.";
}

sealed class Store
{
    public List<PrumoTimer> Timers { get; private set; } = [];
    public AppSettings Settings { get; private set; } = new();
    public Action<PrumoTimer>? OnFire { get; set; }
    public event Action? Changed;

    readonly string _path;
    readonly System.Windows.Forms.Timer _ticker = new() { Interval = 250 };

    public Store()
    {
        var dir = Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.ApplicationData), "Prumo");
        Directory.CreateDirectory(dir);
        _path = Path.Combine(dir, "state.json");
        _ticker.Tick += (_, _) => Tick();
    }

    public PrumoTimer? NextRunning =>
        Timers.Where(t => t.Status == TimerStatus.Running).MinBy(t => t.EndsAt);

    public void Load()
    {
        try
        {
            if (!File.Exists(_path)) return;
            var state = JsonSerializer.Deserialize<PersistedState>(File.ReadAllText(_path), JsonOpts);
            if (state is null) return;
            Timers = state.Timers;
            Settings = state.Settings;
        }
        catch { /* first run or corrupt file */ }
    }

    public void Save()
    {
        try
        {
            var state = new PersistedState { Timers = Timers, Settings = Settings };
            File.WriteAllText(_path, JsonSerializer.Serialize(state, JsonOpts));
        }
        catch { /* ignore */ }
    }

    public void StartTicking() => _ticker.Start();

    public void AddTimer(string title, int durationMs)
    {
        var now = DateTimeOffset.UtcNow.ToUnixTimeMilliseconds();
        var timer = new PrumoTimer
        {
            Id = Guid.NewGuid().ToString(),
            Title = title.Trim(),
            DurationMs = durationMs,
            StartedAt = now,
            EndsAt = now + durationMs,
            Status = TimerStatus.Running,
        };
        Timers.Insert(0, timer);
        if (Timers.Count > 40) Timers = Timers.Take(40).ToList();
        Settings.SeenOnboarding = true;
        Save();
        Changed?.Invoke();
    }

    public void Cancel(string id)
    {
        Timers.RemoveAll(t => t.Id == id);
        Save();
        Changed?.Invoke();
    }

    public void Patch(Action<AppSettings> block)
    {
        block(Settings);
        Save();
        Changed?.Invoke();
    }

    void Tick()
    {
        var now = DateTimeOffset.UtcNow.ToUnixTimeMilliseconds();
        var fired = new List<PrumoTimer>();
        foreach (var t in Timers)
        {
            if (t.Status == TimerStatus.Running && t.EndsAt <= now)
            {
                t.Status = TimerStatus.Fired;
                fired.Add(t);
            }
        }
        if (fired.Count > 0)
        {
            Save();
            foreach (var t in fired) OnFire?.Invoke(t);
        }
        Changed?.Invoke();
    }

    static readonly JsonSerializerOptions JsonOpts = new()
    {
        PropertyNamingPolicy = JsonNamingPolicy.CamelCase,
        Converters = { new JsonStringEnumConverter(JsonNamingPolicy.CamelCase) },
        WriteIndented = true,
    };
}

enum TaskbarEdge { Bottom, Top, Left, Right }

static class Taskbar
{
    public static TaskbarEdge Edge()
    {
        var s = Screen.PrimaryScreen ?? Screen.AllScreens[0];
        var wa = s.WorkingArea;
        var b = s.Bounds;
        if (wa.Top > b.Top) return TaskbarEdge.Top;
        if (wa.Bottom < b.Bottom) return TaskbarEdge.Bottom;
        if (wa.Left > b.Left) return TaskbarEdge.Left;
        return TaskbarEdge.Right;
    }

    /// Distance pulled from the tray toward the work area (pixels).
    public static int PullDistance(Point origin, Point now) => Edge() switch
    {
        TaskbarEdge.Bottom => origin.Y - now.Y,
        TaskbarEdge.Top => now.Y - origin.Y,
        TaskbarEdge.Left => now.X - origin.X,
        _ => origin.X - now.X,
    };

    public static float ViewportSpan()
    {
        var s = Screen.FromPoint(Cursor.Position);
        return Edge() is TaskbarEdge.Left or TaskbarEdge.Right ? s.Bounds.Width : s.Bounds.Height;
    }
}
