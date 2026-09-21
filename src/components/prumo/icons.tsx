import { cn } from "@/lib/utils";

/** Geometric mason plumb — cone, nut, eyelet. Not a drop. */
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
        d="M12 1.6v7.1"
        fill="none"
        stroke="currentColor"
        strokeWidth="1.5"
        strokeLinecap="round"
      />
      <circle
        cx="12"
        cy="10.2"
        r="1.7"
        fill="none"
        stroke="currentColor"
        strokeWidth="1.4"
      />
      <rect
        x="9.1"
        y="11.7"
        width="5.8"
        height="2.15"
        rx="0.35"
        fill="currentColor"
      />
      <path
        d="M6.8 14h10.4L12 30.5z"
        fill={filled ? "currentColor" : "none"}
        stroke="currentColor"
        strokeWidth="1.3"
        strokeLinejoin="round"
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
