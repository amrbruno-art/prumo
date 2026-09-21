import { cn } from "@/lib/utils";

/** Geometric plumb bob — original mark, not a clock. */
export function PlumbBob({
  className,
  filled = true,
}: {
  className?: string;
  filled?: boolean;
}) {
  return (
    <svg
      viewBox="0 0 24 32"
      className={cn("block", className)}
      aria-hidden="true"
    >
      <path
        d="M12 3.2c-3.05 0-5.5 2.28-5.5 5.35 0 1.42.5 2.72 1.35 3.74L12 28.4l4.15-16.11c.85-1.02 1.35-2.32 1.35-3.74 0-3.07-2.45-5.35-5.5-5.35z"
        fill={filled ? "currentColor" : "none"}
        stroke="currentColor"
        strokeWidth="1.4"
        strokeLinejoin="round"
      />
      <circle
        cx="12"
        cy="8.4"
        r="2.35"
        fill={filled ? "var(--color-bob-core)" : "none"}
        stroke="currentColor"
        strokeWidth="1.2"
      />
    </svg>
  );
}

export function PlumbWell({ className }: { className?: string }) {
  return (
    <svg viewBox="0 0 24 24" className={cn("block", className)} aria-hidden="true">
      <circle
        cx="12"
        cy="12"
        r="5.5"
        fill="none"
        stroke="currentColor"
        strokeWidth="1.6"
      />
      <circle cx="12" cy="12" r="1.4" fill="currentColor" />
    </svg>
  );
}
