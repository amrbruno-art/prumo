let ctx: AudioContext | null = null;

function getCtx() {
  if (typeof window === "undefined") return null;
  if (!ctx) {
    const AC =
      window.AudioContext ||
      (window as unknown as { webkitAudioContext: typeof AudioContext })
        .webkitAudioContext;
    ctx = new AC();
  }
  return ctx;
}

/** Original two-note chime — not a system alert copy. */
export async function playChime() {
  const ac = getCtx();
  if (!ac) return;
  if (ac.state === "suspended") {
    try {
      await ac.resume();
    } catch {
      return;
    }
  }
  const now = ac.currentTime;
  const notes = [
    { freq: 392, at: 0, dur: 0.9 },
    { freq: 523.25, at: 0.14, dur: 1.05 },
  ];
  for (const n of notes) {
    const o = ac.createOscillator();
    const g = ac.createGain();
    o.type = "sine";
    o.frequency.value = n.freq;
    g.gain.setValueAtTime(0, now + n.at);
    g.gain.linearRampToValueAtTime(0.07, now + n.at + 0.03);
    g.gain.exponentialRampToValueAtTime(0.001, now + n.at + n.dur);
    o.connect(g);
    g.connect(ac.destination);
    o.start(now + n.at);
    o.stop(now + n.at + n.dur + 0.05);
  }
}

export function nativeNotify(title: string, body: string) {
  if (typeof window === "undefined") return;
  if (!("Notification" in window)) return;
  if (Notification.permission !== "granted") return;
  try {
    new Notification(title, { body, silent: true });
  } catch {
    /* ignore — browsers may block from insecure contexts */
  }
}

export async function requestNotifyPermission(): Promise<boolean> {
  if (typeof window === "undefined" || !("Notification" in window)) return false;
  if (Notification.permission === "granted") return true;
  if (Notification.permission === "denied") return false;
  try {
    const res = await Notification.requestPermission();
    return res === "granted";
  } catch {
    return false;
  }
}
