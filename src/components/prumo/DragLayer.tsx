import { useMemo } from "react";
import { formatDuration, formatEndTime } from "@/lib/prumo/format";
import {
  dragToMinutes,
  minutesToDistance,
  minutesToMs,
  SNAP_MINUTES,
  snapMinutes,
} from "@/lib/prumo/mapping";
import { messages } from "@/lib/prumo/i18n";
import type { DragState, Lang } from "@/lib/prumo/types";
import { PlumbBob } from "./icons";

type Props = {
  drag: DragState;
  lang: Lang;
  snap: boolean;
  viewportH: number;
};

export function resolveDrag(drag: DragState, viewportH: number, snap: boolean) {
  const distance = Math.max(0, drag.y - drag.originY);
  const raw = dragToMinutes(distance, viewportH, drag.alt);
  const minutes = snapMinutes(raw, snap, drag.shift);
  const snappedY = drag.originY + minutesToDistance(minutes, viewportH, drag.alt);
  return { minutes, ms: minutesToMs(minutes), bobX: drag.originX, bobY: snappedY };
}

export function DragLayer({ drag, lang, snap, viewportH }: Props) {
  const t = messages[lang];
  const resolved = resolveDrag(drag, viewportH, snap);
  const { minutes, ms, bobX, bobY } = resolved;
  const ends = Date.now() + ms;
  const hudLeft = bobX > 210;
  const ticks = useMemo(() => {
    const list: Array<{ y: number; label: string; major: boolean }> = [];
    const seen = new Set<number>();
    for (const m of SNAP_MINUTES) {
      if (m > minutes) break;
      if (drag.alt && m < 15) continue;
      const y = drag.originY + minutesToDistance(m, viewportH, drag.alt);
      if (y > bobY - 8) continue;
      if (seen.has(m)) continue;
      seen.add(m);
      const major = m === 5 || m === 10 || m === 15 || m === 25 || m === 30 || m % 60 === 0;
      if (!major && m > 30) continue;
      list.push({
        y,
        label: m < 1 ? (lang === "pt" ? "30s" : "30s") : m % 60 === 0 ? `${m / 60}h` : `${m}`,
        major,
      });
    }
    return list;
  }, [bobY, drag.alt, drag.originY, lang, minutes, viewportH]);

  const hudStyle = hudLeft
    ? { top: bobY - 28, left: Math.max(12, bobX - 196) }
    : { top: bobY - 28, left: bobX + 28 };

  return (
    <>
      <svg className="drag-svg" aria-hidden="true">
        <line
          x1={drag.originX}
          y1={drag.originY}
          x2={bobX}
          y2={bobY}
          stroke="var(--color-cord)"
          strokeWidth="1.6"
          strokeLinecap="round"
        />
        {ticks.map((tick) => (
          <g key={tick.y}>
            <line
              x1={bobX - (tick.major ? 9 : 5)}
              y1={tick.y}
              x2={bobX + (tick.major ? 9 : 5)}
              y2={tick.y}
              stroke="var(--color-cord)"
              strokeOpacity={tick.major ? 0.9 : 0.45}
              strokeWidth="1.2"
            />
            {tick.major ? (
              <text
                x={bobX + 14}
                y={tick.y + 3}
                fill="var(--color-cord)"
                fontSize="10"
                fontFamily="var(--font-mono)"
                opacity="0.7"
              >
                {tick.label}
              </text>
            ) : null}
          </g>
        ))}
      </svg>
      <div
        className="pointer-events-none absolute z-50 text-cord"
        style={{
          left: bobX,
          top: bobY,
          transform: "translate(-50%, -8px)",
          filter: "drop-shadow(0 6px 10px color-mix(in oklab, #14171c 45%, transparent))",
        }}
      >
        <PlumbBob className="h-8 w-6" />
      </div>
      <div className="glass-panel hud" style={hudStyle}>
        <div className="hud-time">{formatDuration(ms, lang)}</div>
        <div className="hud-end">
          {t.endsAt} {formatEndTime(ends, lang)}
        </div>
        {drag.alt ? <span className="hud-chip">{t.stretch}</span> : null}
      </div>
    </>
  );
}
