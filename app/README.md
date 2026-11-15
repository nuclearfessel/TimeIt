# Timed (Flutter app)

Workout interval timer for **iOS and Android only** (no web, desktop, or watch targets).

## Features (v1)
- Simple timers: standby, work, rest, rounds
- Advanced timers: stack standby / work / rest phases, repeat by cycles
- Create, edit, delete your own timers (no pre-built exercises)
- Full-screen phase colors and alert sounds (phase change, last-3 countdown, complete)
- Settings: Light / Dark (not system), sound preference stubs
- Portrait and landscape for all screens
- Free — no monetization; **iOS + Android only** (no Apple Watch / Wear OS / web / desktop)
- Fonts: Hepta Slab (digits / headers), Plus Jakarta Sans (UI)

## Run
```bash
cd app
flutter pub get
flutter run
```

On this Windows machine you can run Android emulator or a Windows desktop smoke test. iOS builds need a Mac.

## Stack
Flutter (Dart) — one codebase for both stores.
