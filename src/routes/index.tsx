import { createFileRoute } from "@tanstack/react-router";
import { MacDesktop } from "@/components/prumo/MacDesktop";

export const Route = createFileRoute("/")({ component: Home });

function Home() {
  return <MacDesktop />;
}
