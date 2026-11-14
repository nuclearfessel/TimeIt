# Instructions for any AI assistant working on Timed

Read this first. It carries everything the project owner has told the previous assistant, so you can continue without the earlier conversation. Then read `README.md`, `docs/reference-apps.md` and `docs/research.md`.

The owner will continue this work in **Cursor**. Cursor reads this `AGENTS.md` and the rule in `.cursor/rules/timed.mdc`, which points back here.

## Who and what
- The owner is a **designer** who wants to create a **new interval timer app for iOS and Android**.
- **Building has started** (owner asked 2026-11-13). App code lives in `app/` on branch `feature/flutter-interval-timer`. Keep research docs; do not invent scope beyond what the owner decided.
- Local folder: `D:\ClaudeLocalExperiments\Timed` (Windows). GitHub: private repo `nuclearfessel/Timed`, branch `main`.

## Owner's instructions (verbatim intent)
1. **Research before building.** The owner explicitly said nothing should be built yet and wanted research first, then asked for deep research on interval timers on both Android and iOS.
2. **Collect screens from both app stores and the web**, covering free, shareware, open-source and paid apps. **No Pomodoro** apps or capabilities.
3. **Organize reference screens by pattern** (run screen, editor, presets, history, themes, widgets/Watch, marketing).
4. **Shortlist three apps** that have basic and advanced timers, including stacking work and rest timers. Result: **Seconds, Intervals Pro, Allez**.
5. **Do not add pre-built exercises.** The app must let users **create and delete their own default timers and timer sets**.
6. **Reduce the reference board to only the shortlisted apps.**
7. **Typefaces (Google Fonts):** **Hepta Slab** for large numbers (timer digits) and headers; **Plus Jakarta Sans** for everything else.
8. **GitHub repo named `Timed`** (created as private).
9. **Save the info locally** so the work can continue in a non-Claude AI app. That is why this file exists.
10. **Shipping targets only:** an **Android app** and an **iOS app** (phone apps).
11. **Keep the GitHub repo private for now.**
12. **Product intent (owner, 2026-11-13):** workout interval timer with **simple and advanced** timers. Advanced stacks **standby, work, and rest** timers. **Alert sounds.** **One tech stack**, deployable to both iOS and Android (not separate native codebases).

## Decisions so far
- Lead use case: working out (interval training).
- Simple timers and advanced timers; advanced stacks standby, work, and rest. Alert sounds. User-created timers and sets only. No Pomodoro. No pre-built exercises.
- Fonts as above. Hepta Slab and Plus Jakarta Sans are already installed on the owner's Windows machine (user fonts).
- Reference apps: Seconds (iOS and Android), Intervals Pro (iOS), Allez (Android).
- Platforms: iOS app and Android app only.
- Tech: **Flutter** (one codebase → iOS + Android). Chosen when the owner asked to build. Research still notes native strengths for Live Activity / AlarmKit / Watch if those matter later; see `docs/research.md` section 4.
- Repo visibility: private for now (`nuclearfessel/Timed`).
- Landscape: only Seconds is confirmed (iOS by listing and review; Android very likely from a screenshot). Intervals Pro and Allez are unconfirmed, so test them.

## Open questions for the owner
1. Monetization: one-time Pro, lifetime, optional subscription?
2. Apple Watch app in v1? (Owner said phone apps only so far; confirm Watch is out or later.)
3. Should the run screen support landscape?
4. Restyle `reference/index.html` in Hepta Slab and Plus Jakarta Sans? (Asked, not answered.)
5. Richer cues later (voice / custom sounds), or keep current beeps?

## How the owner likes to work (observed)
- Confirm before outward-facing or hard-to-undo actions: they approved each of these explicitly before it happened (downloading files, creating the repo, committing and pushing). Keep doing that — **except** for the trigger phrases below.
- Do research and planning first; show findings; ask before moving to the next phase.
- Be honest about evidence: separate what was verified, what is secondary or inferred, and what is unknown. Say when something was not tested hands-on.
- Pronouns: the owner's are not stated; use they/them.
- Keep answers concise and plain.

## Workflow trigger phrases (owner, 2026-11-14)
Full detail: `.cursor/rules/workflow-triggers.mdc`.
1. **`implement` / `implement it`** (case-insensitive) or **`New!`** (case-sensitive): create and check out `feature-update-<YYYYMMDD-HHmmss>`, then continue the request.
2. **`Go!`** (case-sensitive): commit, push, merge to `main`, start release builds, then clean/delete merged feature branches (never delete `main`). `Go!` is explicit approval for those steps.

## Project contents
- `README.md`: overview, decisions, open questions.
- `app/`: Flutter app (iOS + Android).
- `docs/reference-apps.md`: shortlist details, why others were dropped, hands-on test checklist.
- `docs/research.md`: market, design, accessibility and technical research with evidence tags and gaps.
- `reference/index.html`: single-file screen reference board. Two views (By app, By pattern), platform and model filters. Open directly in a browser; it needs internet because store screenshots are hotlinked from Apple and Google Play (nothing was stored in the repo). Each screenshot has a pattern tag in the `TAGS` object in the file.

## Technical notes for the reference board
- Plain HTML, CSS and JavaScript; no build step. App data lives in the `apps` array, pattern tags in `TAGS`, pattern definitions in `PATTERNS`.
- iOS image URLs are built from `https://is1-ssl.mzstatic.com/image/thumb/<path>/392x696bb.<ext>`; Google Play images from `https://play-lh.googleusercontent.com/<id>=h560`.
- If you build DOM in a browser tool with Trusted Types enabled (Google Play, F-Droid pages), use `createElement` and `replaceChildren`, not `innerHTML`.

## Known gaps and cautions
- Everything about the apps comes from store pages, screenshots, reviews and web searches. Nothing is from hands-on use, so create, edit and delete flows are unverified.
- Not accessed: Google Play ratings and installs (only tracker sites), Reddit, Mobbin, Dribbble. Apple HIG pages did not load, so HIG points are from memory.
- Not collected yet: Live Activity, widget, Apple Watch and Wear OS screens.
- Third-party revenue and install figures are unreliable estimates.
- Store screenshots belong to their owners; keep the board for private reference.

## Suggested next steps
1. Owner answers the open questions above.
2. Hands-on test the three shortlisted apps (checklist in `docs/reference-apps.md`).
3. Collect Live Activity, widget, Watch and Wear OS screens.
4. Design: phase color tokens, run screen, stacked-timer editor (create, edit, delete timers and sets), announcement model for screen readers, audio policy.
5. Only then start building.
