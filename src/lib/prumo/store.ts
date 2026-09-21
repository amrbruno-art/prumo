import { create } from "zustand";
import { persist } from "zustand/middleware";
import type { Settings, Timer, Toast } from "./types";

const defaultSettings: Settings = {
  language: "pt",
  showCountdown: true,
  showSeconds: true,
  snap: true,
  sound: true,
  notifications: false,
};

type PrumoState = {
  timers: Timer[];
  toasts: Toast[];
  settings: Settings;
  seenOnboarding: boolean;
  readmeOpen: boolean;
  popoverOpen: boolean;
  popoverView: "list" | "settings" | "about";
  hydrated: boolean;
  setHydrated: (v: boolean) => void;
  setPopoverOpen: (open: boolean) => void;
  setPopoverView: (view: PrumoState["popoverView"]) => void;
  setReadmeOpen: (open: boolean) => void;
  patchSettings: (patch: Partial<Settings>) => void;
  setSeenOnboarding: (v: boolean) => void;
  addTimer: (title: string, durationMs: number) => Timer;
  cancelTimer: (id: string) => void;
  snoozeToast: (toastId: string, minutes?: number) => void;
  dismissToast: (toastId: string) => void;
  fireDue: (now?: number) => Timer[];
  clearDone: () => void;
};

function nid() {
  return crypto.randomUUID();
}

export const usePrumo = create<PrumoState>()(
  persist(
    (set, get) => ({
      timers: [],
      toasts: [],
      settings: defaultSettings,
      seenOnboarding: false,
      readmeOpen: false,
      popoverOpen: false,
      popoverView: "list",
      hydrated: false,
      setHydrated: (v) => set({ hydrated: v }),
      setPopoverOpen: (open) =>
        set({ popoverOpen: open, popoverView: open ? get().popoverView : "list" }),
      setPopoverView: (popoverView) => set({ popoverView }),
      setReadmeOpen: (readmeOpen) => set({ readmeOpen }),
      patchSettings: (patch) =>
        set({ settings: { ...get().settings, ...patch } }),
      setSeenOnboarding: (seenOnboarding) => set({ seenOnboarding }),
      addTimer: (title, durationMs) => {
        const now = Date.now();
        const timer: Timer = {
          id: nid(),
          title: title.trim(),
          durationMs,
          startedAt: now,
          endsAt: now + durationMs,
          status: "running",
        };
        set({
          timers: [timer, ...get().timers].slice(0, 40),
          seenOnboarding: true,
        });
        return timer;
      },
      cancelTimer: (id) =>
        set({
          timers: get().timers.filter((t) => t.id !== id),
          toasts: get().toasts.filter((t) => t.timerId !== id),
        }),
      snoozeToast: (toastId, minutes = 5) => {
        const toast = get().toasts.find((t) => t.id === toastId);
        if (!toast) return;
        const now = Date.now();
        const durationMs = minutes * 60_000;
        const timer: Timer = {
          id: nid(),
          title: toast.title,
          durationMs,
          startedAt: now,
          endsAt: now + durationMs,
          status: "running",
        };
        set({
          timers: [
            timer,
            ...get().timers.map((t) =>
              t.id === toast.timerId ? { ...t, status: "dismissed" as const } : t,
            ),
          ].slice(0, 40),
          toasts: get().toasts.filter((t) => t.id !== toastId),
        });
      },
      dismissToast: (toastId) => {
        const toast = get().toasts.find((t) => t.id === toastId);
        set({
          toasts: get().toasts.filter((t) => t.id !== toastId),
          timers: get().timers.map((t) =>
            toast && t.id === toast.timerId
              ? { ...t, status: "dismissed" as const }
              : t,
          ),
        });
      },
      fireDue: (now = Date.now()) => {
        const due = get().timers.filter(
          (t) => t.status === "running" && t.endsAt <= now,
        );
        if (!due.length) return [];
        const toasts: Toast[] = due.map((t) => ({
          id: nid(),
          timerId: t.id,
          title: t.title,
          createdAt: now,
        }));
        set({
          timers: get().timers.map((t) =>
            due.some((d) => d.id === t.id)
              ? { ...t, status: "fired" as const }
              : t,
          ),
          toasts: [...toasts, ...get().toasts].slice(0, 8),
        });
        return due;
      },
      clearDone: () =>
        set({
          timers: get().timers.filter((t) => t.status === "running"),
        }),
    }),
    {
      name: "prumo-v1",
      skipHydration: true,
      partialize: (s) => ({
        timers: s.timers,
        settings: s.settings,
        seenOnboarding: s.seenOnboarding,
      }),
    },
  ),
);

export function soonestRunning(now = Date.now()) {
  const running = usePrumo
    .getState()
    .timers.filter((t) => t.status === "running" && t.endsAt > now);
  running.sort((a, b) => a.endsAt - b.endsAt);
  return running[0] ?? null;
}
