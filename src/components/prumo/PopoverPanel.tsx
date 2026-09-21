import { Settings2, ChevronLeft, X } from "lucide-react";
import { formatEndTime, formatRemaining } from "@/lib/prumo/format";
import { messages } from "@/lib/prumo/i18n";
import { requestNotifyPermission } from "@/lib/prumo/sound";
import { usePrumo } from "@/lib/prumo/store";
import type { Timer } from "@/lib/prumo/types";
import { cn } from "@/lib/utils";
import { PlumbBob } from "./icons";

function Toggle({
  checked,
  onChange,
  label,
}: {
  checked: boolean;
  onChange: (v: boolean) => void;
  label: string;
}) {
  return (
    <button
      type="button"
      role="switch"
      aria-checked={checked}
      aria-label={label}
      className="toggle"
      onClick={() => onChange(!checked)}
    />
  );
}

function TimerRow({
  timer,
  now,
  showSeconds,
  onCancel,
}: {
  timer: Timer;
  now: number;
  showSeconds: boolean;
  onCancel: () => void;
}) {
  const remaining = Math.max(0, timer.endsAt - now);
  const pct = Math.max(0, Math.min(100, (remaining / timer.durationMs) * 100));
  return (
    <div className="timer-row">
      <span className="timer-name">{timer.title || "—"}</span>
      <span className="timer-meta">{formatRemaining(remaining, showSeconds)}</span>
      <button
        type="button"
        className="icon-btn size-7"
        aria-label="Cancel"
        onClick={onCancel}
      >
        <X className="size-3.5 text-muted" />
      </button>
      <div className="track">
        <span style={{ width: `${pct}%` }} />
      </div>
    </div>
  );
}

export function PopoverPanel({
  iconLeft,
  now,
}: {
  iconLeft: number;
  now: number;
}) {
  const lang = usePrumo((s) => s.settings.language);
  const t = messages[lang];
  const view = usePrumo((s) => s.popoverView);
  const setView = usePrumo((s) => s.setPopoverView);
  const settings = usePrumo((s) => s.settings);
  const patch = usePrumo((s) => s.patchSettings);
  const timers = usePrumo((s) => s.timers);
  const cancelTimer = usePrumo((s) => s.cancelTimer);
  const clearDone = usePrumo((s) => s.clearDone);
  const setSeen = usePrumo((s) => s.setSeenOnboarding);
  const setPopoverOpen = usePrumo((s) => s.setPopoverOpen);

  const running = timers.filter((tm) => tm.status === "running");
  const done = timers.filter((tm) => tm.status === "fired" || tm.status === "dismissed");
  const left = Math.max(8, iconLeft - 280);

  return (
    <div
      className="glass-panel popover"
      style={{ left, right: "auto" }}
      role="dialog"
      aria-label={t.appName}
    >
      <div className="popover-inner">
        <div className="popover-head">
          {view !== "list" ? (
            <button
              type="button"
              className="icon-btn"
              aria-label={t.back}
              onClick={() => setView("list")}
            >
              <ChevronLeft className="size-4" />
            </button>
          ) : (
            <PlumbBob className="h-5 w-4 text-ink" />
          )}
          <span className="popover-title">
            {view === "settings" ? t.settings : view === "about" ? t.about : t.appName}
          </span>
          {view === "list" ? (
            <button
              type="button"
              className="icon-btn"
              aria-label={t.settings}
              onClick={() => setView("settings")}
            >
              <Settings2 className="size-4" />
            </button>
          ) : (
            <span className="w-8" />
          )}
        </div>

        {view === "list" ? (
          <div>
            {running.length === 0 ? (
              <div className="empty-block">
                <PlumbBob className="mx-auto h-8 w-6 text-pewter" />
                <p className="mt-3 font-medium text-ink">{t.empty}</p>
                <p>{t.emptyHint}</p>
              </div>
            ) : (
              <>
                <div className="section-label">{t.active}</div>
                {running.map((tm) => (
                  <TimerRow
                    key={tm.id}
                    timer={tm}
                    now={now}
                    showSeconds={settings.showSeconds}
                    onCancel={() => cancelTimer(tm.id)}
                  />
                ))}
              </>
            )}
            {done.length > 0 ? (
              <>
                <div className="section-label">{t.done}</div>
                {done.slice(0, 6).map((tm) => (
                  <div key={tm.id} className="timer-row">
                    <span className="timer-name">{tm.title || t.untitled}</span>
                    <span className="timer-meta">
                      {formatEndTime(tm.endsAt, lang)}
                    </span>
                    <span />
                  </div>
                ))}
                <button type="button" className="text-btn" onClick={clearDone}>
                  {t.clearDone}
                </button>
              </>
            ) : null}
          </div>
        ) : null}

        {view === "settings" ? (
          <div>
            <div className="setting-row">
              <span>{t.countdown}</span>
              <Toggle
                label={t.countdown}
                checked={settings.showCountdown}
                onChange={(v) => patch({ showCountdown: v })}
              />
            </div>
            <div className="setting-row">
              <span>{t.seconds}</span>
              <Toggle
                label={t.seconds}
                checked={settings.showSeconds}
                onChange={(v) => patch({ showSeconds: v })}
              />
            </div>
            <div className="setting-row">
              <span>{t.snap}</span>
              <Toggle
                label={t.snap}
                checked={settings.snap}
                onChange={(v) => patch({ snap: v })}
              />
            </div>
            <div className="setting-row">
              <span>{t.sound}</span>
              <Toggle
                label={t.sound}
                checked={settings.sound}
                onChange={(v) => patch({ sound: v })}
              />
            </div>
            <div className="setting-row">
              <span>{t.notifications}</span>
              <Toggle
                label={t.notifications}
                checked={settings.notifications}
                onChange={async (v) => {
                  if (v) {
                    const ok = await requestNotifyPermission();
                    patch({ notifications: ok });
                  } else {
                    patch({ notifications: false });
                  }
                }}
              />
            </div>
            <div className="setting-row">
              <span>{t.language}</span>
              <div className="lang-seg">
                <button
                  type="button"
                  className={cn(settings.language === "pt" && "is-on")}
                  onClick={() => patch({ language: "pt" })}
                >
                  PT
                </button>
                <button
                  type="button"
                  className={cn(settings.language === "en" && "is-on")}
                  onClick={() => patch({ language: "en" })}
                >
                  EN
                </button>
              </div>
            </div>
            <button
              type="button"
              className="text-btn"
              onClick={() => {
                setSeen(false);
                setPopoverOpen(false);
              }}
            >
              {t.tutorial}
            </button>
            <button
              type="button"
              className="text-btn"
              onClick={() => setView("about")}
            >
              {t.about}
            </button>
          </div>
        ) : null}

        {view === "about" ? (
          <div className="window-body pt-1">
            <p>{t.aboutBody}</p>
            <span className="badge">{t.license}</span>
          </div>
        ) : null}
      </div>
    </div>
  );
}
