export type Lang = "pt" | "en";

export type TimerStatus = "running" | "fired" | "dismissed";

export type Timer = {
  id: string;
  title: string;
  durationMs: number;
  startedAt: number;
  endsAt: number;
  status: TimerStatus;
};

export type Toast = {
  id: string;
  timerId: string;
  title: string;
  createdAt: number;
};

export type Settings = {
  language: Lang;
  showCountdown: boolean;
  showSeconds: boolean;
  snap: boolean;
  sound: boolean;
  notifications: boolean;
};

export type DragState = {
  pointerId: number;
  originX: number;
  originY: number;
  x: number;
  y: number;
  alt: boolean;
  shift: boolean;
};

export type NamingState = {
  durationMs: number;
  x: number;
  y: number;
};
