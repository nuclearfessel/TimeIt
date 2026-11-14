# Timed

A workout interval timer for iOS and Android. Research and references live at the repo root; the Flutter app is in `app/`.

## Decisions so far
- **Scope:** workout interval timer with simple and advanced timers. Advanced stacks **standby, work, and rest**. Alert sounds. No Pomodoro. No pre-built exercises; users create and delete their own timers and sets.
- **Platforms:** iOS app and Android app only, from **one tech stack**.
- **Framework:** **Flutter** (branch `feature/flutter-interval-timer`).
- **Typefaces (Google Fonts):**
  - **Hepta Slab** for large numbers (timer digits) and headers.
  - **Plus Jakarta Sans** for everything else (body, labels, controls).
- **Shortlisted reference apps:** Seconds (iOS + Android), Intervals Pro (iOS), Allez (Android).
- **Repo:** private for now (`nuclearfessel/Timed`).

If you are an AI assistant, read `AGENTS.md` first.

## Contents
- `AGENTS.md`: all of the owner's instructions, decisions and working preferences, for continuing in any AI app.
- `app/`: Flutter app — see `app/README.md`.
- `docs/research.md`: market, design, accessibility and technical research.
- `docs/reference-apps.md`: the shortlist, what each does, and orientation support.
- `reference/index.html`: screen reference board (open in a browser). Views: By app, By pattern. Store images are linked from Apple and Google Play, so it needs internet.

## Open questions
1. Monetization (one-time Pro, lifetime, optional subscription)?
2. Is an Apple Watch app in v1? (Phone apps only so far; confirm Watch is out or later.)
3. Landscape support for the run screen (confirmed only for Seconds; see reference apps).
4. Restyle `reference/index.html` in Hepta Slab and Plus Jakarta Sans?
5. Richer cues later (voice / custom sounds), or keep current beeps?
