# Contributing to Prumo

Thanks for helping. Please read `NOTICE.md`, `DISCLAIMER.md`, and `LICENSE` before opening a pull request.

## Rules

1. **Original work only.** Do not copy Gestimer (or any other commercial timer) names, icons, screenshots, copy, sounds, or distinctive visual layout. Do not submit look-alike branding.
2. Keep the product name **Prumo** and the plumb-bob mark unless there is a strong, discussed reason to change it.
3. Code, comments, and docs in Portuguese or English are welcome.
4. Do not add tracking, ads, or telemetry without a prior issue and explicit opt-in.
5. Do not treat this as a safety-critical alarm. Features should fail visibly, not silently, when the tab is backgrounded.

## Dev setup

See **Install** in `README.md`.

```bash
npm install
npm run dev
npm run typecheck
npm run build
```

## Pull requests

- One concern per PR.
- Describe the user-visible change.
- Do not commit `node_modules`, build output, screenshots, or secrets.
