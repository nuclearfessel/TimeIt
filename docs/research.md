# Interval timer research (iOS + Android)

Date: 2026-11-13. Evidence tags: [V] verified from a primary source, [S] secondary or community source, [I] inference, [?] unverified.

## 1. Landscape
iOS data from the App Store API; Android mostly unverified (Google Play numbers came from tracker sites).

| App | Rating (count) | Model |
|---|---|---|
| Interval Timer, HIIT (Float Tech) | 4.84 (87.5K) | Free, subscription / lifetime; free tier reportedly one workout a day |
| Timer Plus | 4.81 (61.6K) | Free, $2.99/mo, lifetime $9.99-19.99; Watch |
| SmartWOD Timer | 4.94 (54K) | Free (CrossFit) |
| Seconds / Seconds Pro (Runloop) | 4.68 (23.8K) / 4.76 (12.2K) | Free app locks each timer after one run; $7.99 unlock or paid Pro |
| Neo Pixel Interval Timer | 4.49 (19.2K) | Free, subscriptions; Watch is Premium |
| Intervals Pro | 4.77 (13.7K) | Free single timer; $2.99/mo, $19.99/yr, $69.99 lifetime |
| Bit Timer | 4.74 (562) | Free, Pro IAP up to $17.99 |
| Gymboss | 4.68 (847) | Free; hardware timers sold separately |

Top complaints: paywalls and subscriptions; Apple Watch reliability and audio; background and locked-screen failures; ducking control; clunky editing (no mid-list insert, saved timers not editable). Praised: spoken interval names, usable free tiers, standalone Watch operation, clear displays.

## 2. Market opportunity
- Generic HIIT is saturated; incumbents sit at 4.7-4.9 with 12K-87K ratings [V]. Do not compete on feature count.
- Hypothesis [I]: a craft-first timer on one nested-step engine (strength, mobility, physio, breathwork, boxing, EMOM). Boxing, EMOM and physio apps look fragmented and weak on design, but that is unproven.
- Pain points with evidence: Watch-first reliability, music ducking and mixing, nested intervals with per-step cues, fast mid-workout edits, no-account / privacy, fair pricing.
- Pricing norms: one-time $3-8, lifetime $18-70, subscription only where it unlocks ongoing value. Revenue estimates for comparable timers are under $10K/month and unreliable [S].
- Risks: Apple added iPhone-built custom workouts in iOS and watchOS 26 (with reported bugs); free clones keep arriving.

## 3. Design guidance
- Giant tabular numerals. Full-screen phase colors always paired with a text label and an icon. Ring for phase progress, segmented bar for rounds. True-black OLED dark mode. Landscape "across the room" mode.
- Controls: very large, bottom half of the screen, tap-anywhere pause, press-and-hold to stop, no gesture-only actions.
- Editor: list with grouped repeats and accessible reordering (move up / down), presets first, editor deferred. Keep frequent presets one tap away.
- Audio and haptics: distinct tones per cue type, user-set countdown length, voice / beep / silent, duck music then restore, every cue also visual and haptic, global haptics-off.
- Accessibility: WCAG 2.2 target size 24px minimum, 44 for AAA [V]; non-color cues; honor Reduce Motion; do not flash. Screen readers: announce phase changes, not every tick; keep ticking digits out of live regions; opt-in last-3-seconds. Apple HIG details are from memory [?].
- Palette starting point: Okabe-Ito (orange or vermilion work, blue rest, green warm-up) with contrast and color-blind checks [I].

## 4. Technical constraints
- Store absolute timestamps and a precomputed cue schedule; derive state from now minus start. Never count ticks.
- **iOS:** AlarmKit (iOS 26) overrides Silent and Focus [V] but has reports of late firing on locked devices; use it for the final alert, not dense cues. Precise cues via a `.playback` audio session with mixWithOthers / duckOthers, pre-scheduled on AVAudioEngine. Live Activity countdown via `Text(timerInterval:)` runs without updates, but changing phase labels while suspended needs a push. Local notifications are a fallback (64 pending cap, custom sound under 30 s). Watch: extended runtime session or HKWorkoutSession.
- **Android:** foreground service (`mediaPlayback` if playing audio) plus `setAlarmClock` or `setExactAndAllowWhileIdle` as backstop [V]. `USE_EXACT_ALARM` is Play-policy limited to alarm and timer apps (fit unverified). Chronometer notification, optional Android 16 Live Updates. OEM battery killers need user guidance (dontkillmyapp.com) [V]. Wear OS: Health Services plus Ongoing Activity.
- **Framework:** native SwiftUI + Kotlin recommended. Live Activity, AlarmKit UI and the Watch app are Swift regardless. Fallback: Flutter or Expo for UI with native modules for audio, alarms and the service. Share the schedule engine via KMP or shared test vectors.

## 5. Gaps in this research
Google Play numbers, Reddit threads, Mobbin and Dribbble were not accessed. Apple HIG pages did not load. No Live Activity, widget, Apple Watch or Wear OS screens collected yet. Pomodoro, cooking and classroom segments were not researched.

## 6. Suggested next steps
1. Pick the lead use case and platform order.
2. Hands-on test of the three shortlisted apps (see `reference-apps.md`).
3. Read 1-2 star reviews of Seconds, Intervals Pro and Allez; read Reddit directly.
4. Verify Apple HIG, Play exact-alarm policy and AlarmKit limits.
5. Then design: phase color tokens, run screen, editor, announcement model, audio policy.
