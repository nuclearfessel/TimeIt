# Timed

A new interval timer app for iOS and Android, designed by a designer. This repo holds research, references and design decisions. No app code yet.

## Decisions so far
- **Scope:** interval timer with basic and advanced timers, including stacking work and rest timers. No Pomodoro features.
- **Your own timers:** users create and delete their own default timers and timer sets. No pre-built exercises.
- **Typefaces (Google Fonts):**
  - **Hepta Slab** for large numbers (timer digits) and headers.
  - **Plus Jakarta Sans** for everything else (body, labels, controls).
- **Shortlisted reference apps:** Seconds (iOS + Android), Intervals Pro (iOS), Allez (Android).
- **Framework (recommended, not final):** native SwiftUI + Kotlin. See `docs/research.md`.

If you are an AI assistant, read `AGENTS.md` first.

## Contents
- `AGENTS.md`: all of the owner's instructions, decisions and working preferences, for continuing in any AI app.
- `docs/research.md`: market, design, accessibility and technical research.
- `docs/reference-apps.md`: the shortlist, what each does, and orientation support.
- `reference/index.html`: screen reference board (open in a browser). Views: By app, By pattern. Store images are linked from Apple and Google Play, so it needs internet.

## Open questions
1. Which use case to lead with (general routines, boxing/EMOM, mobility/physio, breathwork)?
2. Platform order (iOS first or both) and framework (native vs cross-platform UI)?
3. Monetization (one-time Pro, lifetime, optional subscription)?
4. Is an Apple Watch app in v1?
5. Landscape support for the run screen (confirmed only for Seconds; see reference apps).
