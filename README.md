# Timed

<a href="https://nuclearfessel.github.io/Timed/">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="branding/Graphics/readme-banner-dark.svg">
    <img src="branding/Graphics/readme-banner-light.svg" alt="Timed: create your own standby, work and rest interval routines." width="1600" height="1158">
  </picture>
</a>

A workout interval timer for **iOS and Android only**, built with Flutter.

**Site:** [nuclearfessel.github.io/Timed](https://nuclearfessel.github.io/Timed/) · **Guide:** [Using Timed](https://nuclearfessel.github.io/Timed/guide.html) · **Releases:** [GitHub Releases](https://github.com/nuclearfessel/Timed/releases)

## What it does
- Simple timers: standby, work, rest, rounds
- Advanced timers: stack standby / work / rest, reorder, cycles
- Create, edit, and delete your own timers (no pre-built exercises, no Pomodoro)
- Full-screen phase colors and alert sounds
- Settings: Light / Dark appearance (not system), sound preferences
- Portrait and landscape for the whole app

## Phases
Standby (green), work (orange), and rest (blue) stay consistent in the app, icons, and docs.

<p>
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="branding/Graphics/phases-dark.svg">
    <img src="branding/Graphics/phases-light.svg" alt="Standby, work, and rest phase colors with labels." width="1600" height="900">
  </picture>
</p>

## Simple and advanced
Simple timers cover classic work/rest rounds. Advanced timers let you stack phases in any order, reorder them, and set cycles.

<p>
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="branding/Graphics/timer-types-dark.svg">
    <img src="branding/Graphics/timer-types-light.svg" alt="Simple timer versus advanced stacked phases." width="1600" height="900">
  </picture>
</p>

## Stack
- Flutter (one codebase → iOS + Android only; no web/desktop/watch targets)
- Fonts: **Hepta Slab** (digits / headers), **Plus Jakarta Sans** (UI)
- Brand mark: Interlocking Lanes (standby / work / rest woven together)

## Run
```bash
cd app
flutter pub get
flutter run
```

## Repo layout
- `app/` — Flutter app
- `docs/` — GitHub Pages site and guide (`index.html`, `guide.html`)
- `docs/assets/timed/` — public brand assets for Pages
- `branding/` — full brand package (icons sources, store art, guidelines)
- `docs/research.md`, `docs/reference-apps.md` — research notes
- `reference/index.html` — private screen reference board
- `AGENTS.md` — instructions for AI assistants continuing the work

Timed is free. No monetization. **iOS and Android only** — no web, desktop, Apple Watch, or Wear OS.
