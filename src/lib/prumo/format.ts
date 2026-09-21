import type { Lang } from "./types";

export function formatDuration(ms: number, lang: Lang): string {
  const totalSec = Math.max(0, Math.round(ms / 1000));
  if (totalSec < 60) {
    return lang === "pt" ? `${totalSec} s` : `${totalSec}s`;
  }
  const totalMin = Math.round(totalSec / 60);
  const hours = Math.floor(totalMin / 60);
  const mins = totalMin % 60;
  if (hours === 0) return `${mins} min`;
  if (mins === 0) return lang === "pt" ? `${hours} h` : `${hours}h`;
  return lang === "pt" ? `${hours} h ${mins} min` : `${hours}h ${mins}m`;
}

export function formatRemaining(ms: number, showSeconds: boolean): string {
  const totalSec = Math.max(0, Math.ceil(ms / 1000));
  const hours = Math.floor(totalSec / 3600);
  const mins = Math.floor((totalSec % 3600) / 60);
  const secs = totalSec % 60;
  const pad = (n: number) => n.toString().padStart(2, "0");
  if (!showSeconds) {
    const roundedMin = Math.max(1, Math.ceil(totalSec / 60));
    if (roundedMin >= 60) {
      const h = Math.floor(roundedMin / 60);
      const m = roundedMin % 60;
      return m === 0 ? `${h}h` : `${h}h ${pad(m)}m`;
    }
    return `${roundedMin} min`;
  }
  if (hours > 0) return `${hours}:${pad(mins)}:${pad(secs)}`;
  return `${pad(mins)}:${pad(secs)}`;
}

export function formatEndTime(endsAt: number, lang: Lang): string {
  const d = new Date(endsAt);
  if (lang === "pt") {
    return d.toLocaleTimeString("pt-BR", { hour: "2-digit", minute: "2-digit" });
  }
  return d.toLocaleTimeString("en-US", { hour: "numeric", minute: "2-digit" });
}

export function formatClock(now: number, lang: Lang): string {
  const d = new Date(now);
  if (lang === "pt") {
    return d.toLocaleTimeString("pt-BR", { hour: "2-digit", minute: "2-digit" });
  }
  return d.toLocaleTimeString("en-US", {
    hour: "numeric",
    minute: "2-digit",
  });
}

export function formatClockDate(now: number, lang: Lang): string {
  const d = new Date(now);
  const weekday = d.toLocaleDateString(lang === "pt" ? "pt-BR" : "en-US", {
    weekday: "short",
  });
  const time = formatClock(now, lang);
  return `${weekday} ${time}`;
}
