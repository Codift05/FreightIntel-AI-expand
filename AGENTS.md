# AGENTS.md — Rules for AI agents on FreightIntel AI

> Read this first. It applies to every AI agent (Claude, GPT, Gemini, etc.) that
> edits this repo. Context source of truth: [`docs/PRD.md`](docs/PRD.md).
> Current frontend state: [`docs/FRONTEND.md`](docs/FRONTEND.md) — keep it updated.

## RULE 0 — Documentation is mandatory
Any change to the app MUST be reflected in docs **in the same change**:
- Frontend change → update [`docs/FRONTEND.md`](docs/FRONTEND.md) (what changed, why, new files).
- New decision/convention → add it here or in `docs/FRONTEND.md`.
- Append a dated line to the **Changelog** at the bottom of `docs/FRONTEND.md`.
A change without doc update is unfinished. This is so the next agent (often a
different AI) understands the app without re-reading all code.

## Project in one line
Flutter mobile app (Android/iOS) for Indonesian freight-forwarding finance:
shipments, revenue/cost, profit, dashboard, AI insight. Backend (NestJS +
PostgreSQL) is planned but **not built yet** — frontend uses demo data.

## Scope right now
Frontend only. Mature the UI with demo data. Do not add backend calls yet.
Implementation order follows PRD §13 (Tahap 1 first).

## Hard conventions (do not break)
- **Language:** UI copy in **Bahasa Indonesia**. (Known debt: some labels still
  English — Revenue/Cost/PAID; migrate to ID when touched.)
- **No AI-slop** (antislop): no ALL-CAPS letter-spaced "eyebrow" labels (use
  sentence case), no em-dash `—` in UI text, no fabricated numbers — demo data
  is labelled honestly ("Angka contoh, belum terhubung data").
- **One accent:** green `#17A55B` only for data/positive/primary action, never
  for plain labels.
- **Design tokens only:** colors/radii/shadows/fonts from
  `lib/core/theme/app_theme.dart`. Don't hard-code hex in screens.
- **Reuse components:** `AppCard`, `StatTile`, `Pressable`, `EmptyState`,
  `Sparkline`, `StatusChip`, illustrations via `lib/core/illustrations.dart`.
- **States:** every data screen handles loading / data / empty / error (PRD).
- **Press feedback + haptic** on interactive elements (use `Pressable`).
- **Money = DECIMAL** semantics when backend lands (PRD BR-04); profit = Σrev−Σcost.
- **No Co-Authored-By Claude** in commits (user rule).

## How to run / iterate
- Emulator AVD `expo_review` (has Pixel 6 device frame skin).
- `flutter run -d emulator-5554`. Hot reload = send SIGUSR1 to the run process;
  hot restart = SIGUSR2 (needed after changing a `const` class or adding assets).
- New assets in `pubspec.yaml` need a full rebuild, not hot reload.

## Design & quality skills installed (optional, in ~/.claude/skills)
`apple-design` (HIG audit, Flutter), Emil Kowalski set (`emil-design-eng`,
`choreograph`, `improve-animations`), `antislop` + `antislop-ui`, `ponytail`
(minimal-change coding), `caveman` set (terse token-saving voice + surgical
patch skills). Use them for UI audits and polish.

## Before you finish
1. `flutter analyze lib` is clean (or only pre-existing infos).
2. App runs; you clicked the changed flow.
3. Docs updated per RULE 0.
