# Instructions for any AI assistant working on Timed

Read this first. It carries everything the project owner has told the previous assistant, so you can continue without the earlier conversation. Then read `README.md`, `docs/reference-apps.md` and `docs/research.md`.

The owner will continue this work in **Cursor**. Cursor reads this `AGENTS.md` and the rule in `.cursor/rules/timed.mdc`, which points back here.

## Who and what
- The owner is a **designer** who wants to create a **new interval timer app for iOS and Android**.
- **Building has started** (owner asked 2026-11-13). App code lives in `app/` on branch `feature/flutter-interval-timer`. Keep research docs; do not invent scope beyond what the owner decided.
- Local folder: `D:\ClaudeLocalExperiments\Timed` (Windows). GitHub: public repo `nuclearfessel/Timed`, branch `main`.

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
10. **Shipping targets only:** **iOS and Android only.** No web, desktop, Apple Watch, Wear OS, or other platforms — ever.
11. **GitHub repo visibility:** **public** (`nuclearfessel/Timed`).
12. **Product intent (owner, 2026-11-13):** workout interval timer with **simple and advanced** timers. Advanced stacks **standby, work, and rest** timers. **Alert sounds.** **One tech stack**, deployable to both iOS and Android (not separate native codebases).
12b. **Rounds model (owner, 2026-11-14):** both modes use the word **rounds** (not cycles). Advanced: each round has its **own** phase stack; rounds run in order and may differ from one another.
13. **Monetization (2026-11-14):** none — **completely free**.
14. **Apple Watch / Wear OS:** **never** (covered by iOS + Android only).
15. **Orientation (2026-11-14):** **landscape and portrait for all functions**, not only the run screen.
16. **Reference board fonts:** Hepta Slab + Plus Jakarta Sans (owner: done / required).

## Decisions so far
- Lead use case: working out (interval training).
- Simple timers and advanced timers. Simple uses standby/work/rest plus **rounds**. Advanced uses **rounds**, and each round has its own phase stack (standby/work/rest/…); rounds run in order and may differ. Call them rounds in both modes (not cycles). Alert sounds. User-created timers and sets only. No Pomodoro. No pre-built exercises.
- Fonts as above. Hepta Slab and Plus Jakarta Sans are already installed on the owner's Windows machine (user fonts).
- Reference apps: Seconds (iOS and Android), Intervals Pro (iOS), Allez (Android).
- Platforms: **iOS and Android only.** No web, desktop, Watch, Wear, or anything else.
- Tech: **Flutter** (one codebase → iOS + Android phone apps).
- Repo visibility: **public**. Site/guide via GitHub Pages from `docs/`.
- Monetization: free — no Pro, lifetime, or subscription.
- Orientation: support portrait and landscape across the whole app.
- README is the public app readme (no open-questions list). Keep undecided items in `AGENTS.md` only.

## Open questions for the owner
1. Richer cues later (voice / custom sounds), or keep current beeps?

## How the owner likes to work (observed)
- Confirm before outward-facing or hard-to-undo actions: they approved each of these explicitly before it happened (downloading files, creating the repo, committing and pushing). Keep doing that — **except** for the trigger phrases below.
- Do research and planning first; show findings; ask before moving to the next phase.
- Be honest about evidence: separate what was verified, what is secondary or inferred, and what is unknown. Say when something was not tested hands-on.
- Pronouns: the owner's are not stated; use they/them.
- Keep answers concise and plain.

## Workflow trigger phrases (owner, 2026-11-14)
Full detail: `.cursor/rules/workflow-triggers.mdc`.
1. **`implement` / `implement it`** (case-insensitive) or **`New!`** (case-sensitive): create and check out `feature-update-<YYYYMMDD-HHmmss>`, then continue the request.
2. **`Go!`** (case-sensitive): commit, push, merge to `main`, then clean/delete merged feature branches (never delete `main`). Release builds + GitHub Release run unless scoped (e.g. docs only / no release builds). See `.cursor/rules/workflow-triggers.mdc`.

## Project contents
- `README.md`: public app overview (no open-questions list).
- `app/`: Flutter app (iOS + Android).
- `docs/index.html` + `docs/guide.html` + `docs/site.css`: site + guide (phase-band layout, distinct from Shopped/EncodeIt). Publish like the other apps: `main` → `/docs`.
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
- Not collected yet: Live Activity and widget screens (Watch/Wear are out of scope permanently).
- Third-party revenue and install figures are unreliable estimates.
- Store screenshots belong to their owners; keep the board for private reference.

## Brand package
- Desktop handoff: `C:\Users\bitte\Desktop\Apps\Timed` (Interlocking Lanes, corrected weave).
- Wired into `branding/`, `docs/assets/timed/`, Android `mipmap` / adaptive icons, iOS `AppIcon.appiconset`, and `app/assets/brand/`.

## Suggested next steps
1. Hands-on test the three shortlisted apps when useful (checklist in `docs/reference-apps.md`).
2. Wire music ducking and vibrate stubs from Settings; decide richer cues later.
3. Polish landscape layouts across home, editor, run, and settings.
4. Accessibility: announcement model for screen readers; audio policy.
5. TestFlight via GitHub Actions + App Store Connect API key (Mac or CI).
