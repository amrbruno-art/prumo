import { useEffect, useRef, useState, type PointerEvent as REPointerEvent } from "react";
import { Battery, FileText, Globe, Wifi } from "lucide-react";
import { formatClockDate, formatDuration, formatRemaining } from "@/lib/prumo/format";
import { messages } from "@/lib/prumo/i18n";
import { ACTIVATE_PX } from "@/lib/prumo/mapping";
import { nativeNotify, playChime } from "@/lib/prumo/sound";
import { usePrumo } from "@/lib/prumo/store";
import type { DragState, NamingState } from "@/lib/prumo/types";
import { cn } from "@/lib/utils";
import { DragLayer, resolveDrag } from "./DragLayer";
import { PlumbBob, PlumbWell } from "./icons";
import { PopoverPanel } from "./PopoverPanel";

function useNow(active: boolean) {
  const [now, setNow] = useState(() => Date.now());
  useEffect(() => {
    const id = window.setInterval(() => setNow(Date.now()), active ? 250 : 1000);
    return () => window.clearInterval(id);
  }, [active]);
  return now;
}

function TimerEngine() {
  const running = usePrumo((s) => s.timers.some((t) => t.status === "running"));
  const sound = usePrumo((s) => s.settings.sound);
  const notifications = usePrumo((s) => s.settings.notifications);
  const lang = usePrumo((s) => s.settings.language);

  useEffect(() => {
    if (!running) return;
    const id = window.setInterval(() => {
      const due = usePrumo.getState().fireDue();
      if (!due.length) return;
      const t = messages[usePrumo.getState().settings.language];
      for (const timer of due) {
        if (sound) void playChime();
        if (notifications) {
          nativeNotify(
            t.fired,
            timer.title || t.untitled,
          );
        }
      }
    }, 250);
    return () => window.clearInterval(id);
  }, [running, sound, notifications, lang]);

  return null;
}

export function MacDesktop() {
  const iconRef = useRef<HTMLButtonElement>(null);
  const [hydrated, setHydrated] = useState(false);
  const [drag, setDrag] = useState<DragState | null>(null);
  const [naming, setNaming] = useState<NamingState | null>(null);
  const [iconX, setIconX] = useState(0);
  const [vh, setVh] = useState(800);
  const [title, setTitle] = useState("");
  const pending = useRef<{ x: number; y: number; pointerId: number } | null>(null);

  const settings = usePrumo((s) => s.settings);
  const t = messages[settings.language];
  const timers = usePrumo((s) => s.timers);
  const toasts = usePrumo((s) => s.toasts);
  const popoverOpen = usePrumo((s) => s.popoverOpen);
  const setPopoverOpen = usePrumo((s) => s.setPopoverOpen);
  const seenOnboarding = usePrumo((s) => s.seenOnboarding);
  const setSeenOnboarding = usePrumo((s) => s.setSeenOnboarding);
  const readmeOpen = usePrumo((s) => s.readmeOpen);
  const setReadmeOpen = usePrumo((s) => s.setReadmeOpen);
  const addTimer = usePrumo((s) => s.addTimer);
  const dismissToast = usePrumo((s) => s.dismissToast);
  const snoozeToast = usePrumo((s) => s.snoozeToast);

  const running = timers.some((tm) => tm.status === "running");
  const now = useNow(running || Boolean(drag));
  const next =
    timers
      .filter((tm) => tm.status === "running" && tm.endsAt > now)
      .sort((a, b) => a.endsAt - b.endsAt)[0] ?? null;
  const remaining = next ? next.endsAt - now : 0;
  const progress = next ? Math.max(0, Math.min(1, remaining / next.durationMs)) : 0;

  useEffect(() => {
    void usePrumo.persist.rehydrate();
    usePrumo.getState().setHydrated(true);
    setHydrated(true);
    const measure = () => {
      setVh(window.innerHeight);
      const el = iconRef.current;
      if (el) {
        const r = el.getBoundingClientRect();
        setIconX(r.left + r.width / 2);
      }
    };
    measure();
    window.addEventListener("resize", measure);
    return () => window.removeEventListener("resize", measure);
  }, []);

  useEffect(() => {
    document.documentElement.lang = settings.language === "pt" ? "pt" : "en";
  }, [settings.language]);

  useEffect(() => {
    if (!drag) return;
    const onKey = (e: KeyboardEvent) => {
      if (e.key === "Escape") {
        setDrag(null);
        pending.current = null;
        return;
      }
      setDrag((d) => (d ? { ...d, alt: e.altKey, shift: e.shiftKey } : d));
    };
    window.addEventListener("keydown", onKey);
    window.addEventListener("keyup", onKey);
    return () => {
      window.removeEventListener("keydown", onKey);
      window.removeEventListener("keyup", onKey);
    };
  }, [drag]);

  useEffect(() => {
    if (!naming) return;
    const onKey = (e: KeyboardEvent) => {
      if (e.key === "Escape") commitName("");
    };
    window.addEventListener("keydown", onKey);
    return () => window.removeEventListener("keydown", onKey);
    // commitName is stable enough for this session of naming
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [naming]);

  useEffect(() => {
    if (!popoverOpen) return;
    const onDown = (e: PointerEvent) => {
      const node = e.target as HTMLElement | null;
      if (!node) return;
      if (iconRef.current?.contains(node)) return;
      if (node.closest(".popover")) return;
      setPopoverOpen(false);
    };
    const id = window.setTimeout(() => {
      window.addEventListener("pointerdown", onDown);
    }, 0);
    return () => {
      window.clearTimeout(id);
      window.removeEventListener("pointerdown", onDown);
    };
  }, [popoverOpen, setPopoverOpen]);

  function originFromIcon() {
    const el = iconRef.current;
    if (!el) return { x: iconX, y: 14 };
    const r = el.getBoundingClientRect();
    return { x: r.left + r.width / 2, y: r.bottom - 4 };
  }

  function onPointerDown(e: REPointerEvent<HTMLButtonElement>) {
    if (e.button !== 0) return;
    try {
      e.currentTarget.setPointerCapture(e.pointerId);
    } catch {
      /* synthetic events have no real pointer */
    }
    pending.current = { x: e.clientX, y: e.clientY, pointerId: e.pointerId };
  }

  function onPointerMove(e: REPointerEvent<HTMLButtonElement>) {
    const p = pending.current;
    if (!p || p.pointerId !== e.pointerId) return;
    const origin = originFromIcon();
    const dy = e.clientY - origin.y;
    const dist = Math.hypot(e.clientX - p.x, e.clientY - p.y);
    if (!drag && dist > ACTIVATE_PX && dy > 4) {
      setPopoverOpen(false);
      setSeenOnboarding(true);
      setDrag({
        pointerId: e.pointerId,
        originX: origin.x,
        originY: origin.y,
        x: e.clientX,
        y: e.clientY,
        alt: e.altKey,
        shift: e.shiftKey,
      });
    } else if (drag) {
      setDrag({
        ...drag,
        x: e.clientX,
        y: e.clientY,
        alt: e.altKey,
        shift: e.shiftKey,
      });
    }
  }

  function onPointerUp(e: REPointerEvent<HTMLButtonElement>) {
    const p = pending.current;
    pending.current = null;
    if (p && p.pointerId === e.pointerId) {
      try {
        e.currentTarget.releasePointerCapture(e.pointerId);
      } catch {
        /* already released */
      }
    }
    if (drag) {
      const resolved = resolveDrag(drag, vh, settings.snap);
      setDrag(null);
      if (resolved.minutes >= 0.5) {
        setTitle("");
        setNaming({
          durationMs: resolved.ms,
          x: resolved.bobX,
          y: resolved.bobY,
        });
      }
      return;
    }
    setPopoverOpen(!popoverOpen);
  }

  function commitName(value: string) {
    if (!naming) return;
    addTimer(value, naming.durationMs);
    setNaming(null);
    setTitle("");
  }

  const showOnboarding = hydrated && !seenOnboarding && !drag && !naming;

  return (
    <div
      className={cn("desktop-root", drag && "is-dragging")}
      data-testid="desktop"
    >
      <div className="wallpaper" aria-hidden="true">
        <img src="/wallpaper.jpg" alt="" />
        <div className="wallpaper-veil" />
      </div>

      <header className="menubar">
        <div className="menubar-left">
          <span className="menubar-app">{t.appName}</span>
          <span className="menubar-ghost">{t.fileMenu}</span>
          <span className="menubar-ghost">{t.editMenu}</span>
          <span className="menubar-ghost">{t.windowMenu}</span>
        </div>
        <div className="menubar-right">
          <button
            ref={iconRef}
            type="button"
            className={cn(
              "prumo-icon",
              popoverOpen && "is-open",
              drag && "is-dragging",
            )}
            data-testid="prumo-icon"
            aria-label={t.appName}
            aria-haspopup="dialog"
            aria-expanded={popoverOpen}
            aria-grabbed={Boolean(drag)}
            onPointerDown={onPointerDown}
            onPointerMove={onPointerMove}
            onPointerUp={onPointerUp}
            onPointerCancel={() => {
              pending.current = null;
              setDrag(null);
            }}
            onContextMenu={(e) => e.preventDefault()}
          >
            {drag ? (
              <PlumbWell className="h-4 w-4" />
            ) : (
              <PlumbBob className="h-4 w-3" />
            )}
            {settings.showCountdown && next && !drag ? (
              <span>{formatRemaining(remaining, settings.showSeconds)}</span>
            ) : null}
            {next && !drag ? (
              <span className="progress">
                <span style={{ width: `${progress * 100}%` }} />
              </span>
            ) : null}
          </button>
          <span className="status-item hidden sm:flex" aria-hidden="true">
            <Wifi className="size-3.5" />
          </span>
          <span className="status-item hidden sm:flex" aria-hidden="true">
            <Battery className="size-3.5" />
          </span>
          <span className="status-item tabular-nums">
            {formatClockDate(now, settings.language)}
          </span>
        </div>
      </header>

      {popoverOpen && !drag ? <PopoverPanel iconLeft={iconX} now={now} /> : null}

      {drag ? (
        <DragLayer drag={drag} lang={settings.language} snap={settings.snap} viewportH={vh} />
      ) : null}

      {naming ? (
        <form
          className="glass-panel title-prompt"
          style={{
            top: Math.min(naming.y + 12, vh - 140),
            left: Math.min(Math.max(12, naming.x - 40), window.innerWidth - 292),
          }}
          onSubmit={(e) => {
            e.preventDefault();
            commitName(title);
          }}
        >
          <input
            autoFocus
            value={title}
            placeholder={t.placeholder}
            onChange={(e) => setTitle(e.target.value)}
            maxLength={48}
            aria-label={t.placeholder}
          />
          <div className="title-actions">
            <button type="button" className="btn btn-ghost" onClick={() => commitName("")}>
              {t.skip}
            </button>
            <button type="submit" className="btn btn-solid">
              {t.start}
            </button>
          </div>
        </form>
      ) : null}

      <div className="toast-stack">
        {toasts.map((toast) => {
          const timer = timers.find((tm) => tm.id === toast.timerId);
          return (
            <div key={toast.id} className="glass-panel toast" role="alert">
              <div className="toast-top">
                <span className="inline-flex items-center gap-1.5">
                  <PlumbBob className="h-3.5 w-2.5" />
                  {t.appName}
                </span>
                <span>{t.now}</span>
              </div>
              <p className="toast-title">{t.fired}</p>
              <p className="toast-body">
                {toast.title || t.untitled}
                {timer ? ` · ${formatDuration(timer.durationMs, settings.language)}` : ""}
              </p>
              <div className="toast-actions">
                <button
                  type="button"
                  className="btn btn-ghost"
                  onClick={() => snoozeToast(toast.id)}
                >
                  {t.snooze}
                </button>
                <button
                  type="button"
                  className="btn btn-solid"
                  onClick={() => dismissToast(toast.id)}
                >
                  {t.dismiss}
                </button>
              </div>
            </div>
          );
        })}
      </div>

      {showOnboarding ? (
        <>
          <div
            className="hint-bob"
            style={{ left: iconX }}
            aria-hidden="true"
          >
            <PlumbBob className="h-8 w-6" />
          </div>
          <div className="onboarding">
            <div className="glass-panel onboarding-card">
              <h1>{t.onboardingTitle}</h1>
              <p>{t.onboardingBody}</p>
              <p className="hint-line">{t.holdOption}</p>
              <div className="title-actions mt-5">
                <button
                  type="button"
                  className="btn btn-solid"
                  onClick={() => setSeenOnboarding(true)}
                >
                  {t.gotIt}
                </button>
              </div>
            </div>
          </div>
        </>
      ) : null}

      <button
        type="button"
        className="desk-file"
        onClick={() => setReadmeOpen(true)}
      >
        <span className="desk-file-icon">MIT</span>
        {t.readme}
      </button>

      {readmeOpen ? (
        <div className="glass-panel window" role="dialog" aria-labelledby="readme-title">
          <div className="window-bar">
            <div className="traffic">
              <button type="button" aria-label={t.close} onClick={() => setReadmeOpen(false)} />
              <i />
              <i />
            </div>
            <div className="window-title">{t.readme} — {t.appName}</div>
          </div>
          <div className="window-body">
            <h2 id="readme-title">{t.appName}</h2>
            <p>{t.tagline}</p>
            <p>{t.aboutBody}</p>
            <div className="mt-4 flex flex-wrap gap-2">
              <span className="badge">{t.madeFor}</span>
              <span className="badge">{t.license}</span>
            </div>
          </div>
        </div>
      ) : null}

      <nav className="glass-panel dock" aria-label="Dock">
        <span className="dock-item" aria-hidden="true">
          <FileText className="size-5" />
        </span>
        <span className="dock-item" aria-hidden="true">
          <Globe className="size-5" />
        </span>
        <span className="dock-item is-live" title={t.dockHint}>
          <PlumbBob className="h-6 w-5" />
        </span>
      </nav>

      <TimerEngine />
    </div>
  );
}
