const DRAG_THRESHOLD_PX = 12;

/** Common durations people actually set. Short band is given more screen. */
const SHORT_STOPS: Array<[ratio: number, minutes: number]> = [
  [0, 0.5],
  [0.06, 1],
  [0.11, 2],
  [0.16, 3],
  [0.22, 5],
  [0.3, 8],
  [0.37, 10],
  [0.46, 15],
  [0.54, 20],
  [0.61, 25],
  [0.68, 30],
  [0.76, 45],
  [0.83, 60],
  [0.91, 120],
  [1, 480],
];

/** ⌥ stretches the line into hours, up to a full day. */
const LONG_STOPS: Array<[ratio: number, minutes: number]> = [
  [0, 5],
  [0.1, 15],
  [0.2, 30],
  [0.32, 60],
  [0.44, 120],
  [0.56, 240],
  [0.68, 480],
  [0.82, 720],
  [1, 1440],
];

export const SNAP_MINUTES = [
  0.5, 1, 2, 3, 4, 5, 6, 8, 10, 12, 15, 20, 25, 30, 35, 40, 45, 50, 55, 60, 75,
  90, 105, 120, 150, 180, 240, 300, 360, 480, 600, 720, 960, 1200, 1440,
];

function clamp(n: number, min: number, max: number) {
  return Math.min(max, Math.max(min, n));
}

function lerpStops(t: number, stops: Array<[number, number]>): number {
  if (t <= 0) return stops[0][1];
  if (t >= 1) return stops[stops.length - 1][1];
  for (let i = 1; i < stops.length; i++) {
    const [r1, m1] = stops[i];
    const [r0, m0] = stops[i - 1];
    if (t <= r1) {
      const u = (t - r0) / (r1 - r0);
      return m0 + (m1 - m0) * u;
    }
  }
  return stops[stops.length - 1][1];
}

export function usableTrack(viewportH: number) {
  return Math.max(260, viewportH - 96);
}

export function dragToMinutes(
  distancePx: number,
  viewportH: number,
  stretch: boolean,
): number {
  const usable = usableTrack(viewportH);
  const t = clamp((distancePx - DRAG_THRESHOLD_PX) / usable, 0, 1);
  return lerpStops(t, stretch ? LONG_STOPS : SHORT_STOPS);
}

export function snapMinutes(raw: number, enabled: boolean, precise: boolean): number {
  if (precise) {
    if (raw < 5) return Math.round(raw * 2) / 2;
    return Math.max(1, Math.round(raw));
  }
  if (!enabled) return Math.max(0.5, Math.round(raw * 2) / 2);
  let best = SNAP_MINUTES[0];
  let bestD = Infinity;
  for (const s of SNAP_MINUTES) {
    const d = Math.abs(s - raw);
    if (d < bestD) {
      best = s;
      bestD = d;
    }
  }
  return best;
}

export function minutesToDistance(
  minutes: number,
  viewportH: number,
  stretch: boolean,
): number {
  const usable = usableTrack(viewportH);
  let lo = DRAG_THRESHOLD_PX;
  let hi = DRAG_THRESHOLD_PX + usable;
  for (let i = 0; i < 20; i++) {
    const mid = (lo + hi) / 2;
    if (dragToMinutes(mid, viewportH, stretch) < minutes) lo = mid;
    else hi = mid;
  }
  return (lo + hi) / 2;
}

export function minutesToMs(minutes: number) {
  return Math.round(minutes * 60_000);
}

export const ACTIVATE_PX = 8;
