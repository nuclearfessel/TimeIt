# Timed

A workout interval timer with simple rounds, or advanced rounds each with their own phase stack.

<a href="https://nuclearfessel.github.io/Timed/">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="branding/Graphics/readme-banner-dark.svg">
    <img src="branding/Graphics/readme-banner-light.svg" alt="Timed: make every interval yours. A workout interval timer for iOS and Android." width="1600">
  </picture>
</a>

**Site:** [nuclearfessel.github.io/Timed](https://nuclearfessel.github.io/Timed/) · **Guide:** [Using Timed](https://nuclearfessel.github.io/Timed/guide.html) · **Releases:** [GitHub Releases](https://github.com/nuclearfessel/Timed/releases)

Timed is free. **iOS and Android only** — no web, desktop, Apple Watch, or Wear OS. No Pomodoro. No pre-built exercises.

## Screenshots

<p>
  <img src="docs/assets/timed/Screenshots/01-home.svg" alt="Timed home screen with simple and advanced timers." width="420">
  &nbsp;
  <img src="docs/assets/timed/Screenshots/02-run-portrait.svg" alt="Run screen in portrait: phase color, large digits, up next and controls." width="420">
  &nbsp;
  <img src="docs/assets/timed/Screenshots/05-editor-simple.svg" alt="Simple timer editor with standby, work, rest, and rounds." width="420">
</p>

<p>
  <img src="docs/assets/timed/Screenshots/06-editor-advanced.svg" alt="Advanced editor with rounds, each with their own phase stack." width="420">
  &nbsp;
  <img src="docs/assets/timed/Screenshots/04-settings.svg" alt="Settings with Light and Dark theme and sound toggles." width="420">
</p>

<p>
  <img src="docs/assets/timed/Screenshots/08-run-landscape.svg" alt="Run screen in landscape with the same two-thirds timer and one-third stack layout." width="900">
</p>

## Your session at a glance

Clear phase labels and countdown digits help you follow the session. The illustrated durations are examples, not preset workouts.

<p>
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="branding/Graphics/session-overview-dark.svg">
    <img src="branding/Graphics/session-overview-light.svg" alt="Illustrated standby, work and rest phases with a conceptual timer screen, not a screenshot." width="1600">
  </picture>
</p>

## Features

Create your own timers and sets. Choose simple rounds or build a custom sequence, then edit or delete routines as needed.

- Simple timers: standby, work, rest, rounds
- Advanced timers: rounds, each with its own standby / work / rest stack
- Full-screen phase colors and alert sounds
- Settings: Light / Dark appearance (not system), sound preferences
- Portrait and landscape for the whole app

<p>
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="branding/Graphics/features-dark.svg">
    <img src="branding/Graphics/features-light.svg" alt="Simple timers, advanced stacks and user-created routines." width="1600">
  </picture>
</p>

## Getting started

Choose Simple or Advanced, configure the timer and start. See the [guide](https://nuclearfessel.github.io/Timed/guide.html) for full instructions.

<p>
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="branding/Graphics/workflow-dark.svg">
    <img src="branding/Graphics/workflow-light.svg" alt="Choose a format, build your routine, then start the session." width="1600">
  </picture>
</p>

## Two timer formats

Simple timers run standby once, followed by work/rest rounds, with no rest after the final work interval. Advanced timers are a list of rounds; each round has its own phase stack, so later rounds can differ from earlier ones.

<p>
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="branding/Graphics/timer-types-dark.svg">
    <img src="branding/Graphics/timer-types-light.svg" alt="Simple rounds compared with flexible advanced phase stacks." width="1600">
  </picture>
</p>

## Phase cues

Phase labels and sounds accompany the color cues; meaning does not depend on color alone. Standby is green, work is orange, rest is blue.

<p>
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="branding/Graphics/phases-dark.svg">
    <img src="branding/Graphics/phases-light.svg" alt="Green standby, orange work and blue rest, each identified with text." width="1600">
  </picture>
</p>

## Run controls

Start a session, pause and resume it, skip to the next phase or reset to the first phase.

<p>
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="branding/Graphics/run-controls-dark.svg">
    <img src="branding/Graphics/run-controls-light.svg" alt="Start, Pause/Resume, Skip and Reset explained through an illustrated control diagram." width="1600">
  </picture>
</p>

## Mobile platforms

Timed targets iOS and Android. Check [GitHub Releases](https://github.com/nuclearfessel/Timed/releases) and the [installation guide](https://nuclearfessel.github.io/Timed/guide.html#install) for current packages. iOS distribution requires signing on a Mac.

<p>
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="branding/Graphics/mobile-platforms-dark.svg">
    <img src="branding/Graphics/mobile-platforms-light.svg" alt="Conceptual iOS and Android devices, not app screenshots or store badges." width="1600">
  </picture>
</p>

## Stack
- Flutter (one codebase → iOS + Android only)
- Fonts: **Hepta Slab** (digits / headers), **Plus Jakarta Sans** (UI)
- Brand mark: Interlocking Lanes

## Run
```bash
cd app
flutter pub get
flutter run
```

## Repo layout
- `app/` — Flutter app
- `docs/` — GitHub Pages site and guide
- `docs/assets/timed/` — public brand assets for Pages
- `branding/` — full brand package (icons sources, store art, guidelines)
- `docs/research.md`, `docs/reference-apps.md` — research notes
- `reference/index.html` — private screen reference board
- `AGENTS.md` — instructions for AI assistants continuing the work
