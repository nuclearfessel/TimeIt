# Revamp Timed’s GitHub Pages home and guide

## Scope and inspected source
- Home: https://nuclearfessel.github.io/Timed/
- Guide: https://nuclearfessel.github.io/Timed/guide.html
- Repository: https://github.com/nuclearfessel/Timed
- Public source and both live pages were inspected on 2026-11-14. Recheck before editing.
- Pages source: `docs/index.html`, `docs/guide.html`, shared `docs/site.css`
  and `docs/back-to-top.js`. Inspect the actual Pages configuration before shipping.
- Preserve `reference/index.html`: it is a research board, not the public home page.

Use the same process as the Shopped and EncodeIt handoffs: inspect the existing
pages, preserve their content and behavior, introduce the approved visual identity,
then verify both pages in both themes. Do not copy either sibling app’s design.
This document is an implementation brief, not an already-built or published site.

## Approved identity
Use **Interlocking Lanes**, the corrected three-loop woven symbol, everywhere
the app is identified. Each pair alternates over/under at its two crossings.
Keep the supplied SVG masks intact. Do not replace the mark with the old
half-track, Switchback, Closed Circuit, Track T, a clock or a generic exercise icon.

Use Hepta Slab SemiBold for headings and Plus Jakarta Sans for body/UI.
Keep the green/orange/blue phase meaning and the supplied light/dark tokens.
The mark contains no type. “Ready. Work. Recover.” and
“Make every interval yours.” are separate HTML copy, never text squeezed into
the symbol. Use the mark alone below roughly 160 CSS pixels of lockup space.

## Current page behavior to preserve
**Keep the colored top areas on both pages.** The home hero stacks green,
orange and blue gradients horizontally; the guide uses vertical bands on desktop
and stacked bands on mobile. Their stops are #0F3D32→#009E73,
#8A3C00→#D55E00→#B34A00, and #0072B2→#024A73.
Use **Web/header-logo-on-color.svg** in both topbars. Its neutral light plate
keeps every lane visible on these backgrounds; it is a deliberate protective
logo variant, not a transparency error. Do not use the bare colored mark over
matching phase colors, or assume white lettering is sufficient on the bright stops.
Use the supplied colored-header proof and Web/COLORED-HEADERS.md.

The home page has a phase-sequence explanation, Simple/Advanced descriptions,
Download links and a high-contrast back-to-top control. The guide covers startup,
simple/advanced creation, running, sound, settings and installation.
Both use the same font families and shared top-navigation styling.
Preserve the matching header heights/insets and the back-to-top behavior.
Do not accidentally reinstate earlier issues with invisible navigation controls.

### Home — `docs/index.html`
1. Replace the colored header identity with `Web/header-logo-on-color.svg`.
   Keep navigation to Download, Guide and Source as real keyboard-operable links.
2. Build one semantic HTML hero, not a banner image plus a duplicate large H1.
   Place the woven mark beside “Timed”, a concise interval-timer description,
   and the separate headline “Make every interval yours.”
3. Keep the current release and guide actions. Resolve the current GitHub release
   rather than copying the inspected v1.0.1 into new hardcoded links.
4. Retain the end-to-end session explanation. Use labeled standby/work/rest
   bands with durations and readable HTML text. Decorative color is not the only signal.
5. Explain Simple and Advanced using the supplied features and timer-types
   graphics as supplements, not screenshots or replacements for the prose.
6. Keep the download section and installation caveats. At inspection, Android
   APK/AAB files were offered; iOS distribution still needed signing on a Mac.
   Do not invent App Store/Google Play badges or imply an available signed IPA.
7. Use the supplied social-card PNG for Open Graph, with a verified absolute
   deployed asset URL. Use the favicon set from `Web/`.

### Guide — `docs/guide.html`
1. Keep one descriptive H1 (“Using Timed”), with the protected horizontal logo in
   the shared header. Do not place a large promotional image above every section.
2. Add or refine a compact linked table of contents: sidebar on desktop,
   accessible disclosure on mobile. Keep existing anchor IDs stable.
3. Preserve the complete operational instructions, including optional standby,
   skipped final rest, valid advanced-phase durations and cycle behavior.
4. Running instructions must retain Start, Pause/Resume, Skip, Reset and Done.
   Use HTML ordered lists and actual current screenshots only if available.
5. Keep the sound limitations explicit: lowering music and vibrate-on-alert
   were stored preferences awaiting wiring at inspection. Verify current source;
   never promote a stored setting as an implemented feature.
6. Preserve the app’s explicit Light/Dark choice. The inspected guide says the
   app does not follow system theme. A website theme preference is independent.
7. Use `workflow-{theme}.svg` near getting started and `phases-{theme}.svg` near
   phase explanations, with nearby text equivalents. Do not shrink diagram text
   below readability or repeat the same graphic throughout the guide.

### Existing IDs to preserve
- Home: `top`, `main`, `session-heading`, `download-heading`, `back-to-top`.
- Guide: `top`, `guide`, `start`, `simple`, `advanced`, `run`, `sounds`,
  `settings`, `install`, `back-to-top`.
Keep `#top` for the existing back-to-top behavior, and retain skip links.
If a heading must change, leave a compatible anchor in place.

## Asset mapping and theme behavior
Keep the repository’s archival masters under `branding/`. Copy only public
website assets into `docs/assets/timed/`, preserving the package’s Brand/,
Graphics/, Web/, Fonts/ and Licenses/ relationships. A Pages site serving `docs/`
cannot necessarily load repository-root `branding/` via `../branding/`.

Example from either page:
```html
<link rel="icon" href="assets/timed/Web/favicon.ico">
<img src="assets/timed/Web/header-logo-on-color.svg"
     alt="Timed" class="brand-logo">
```
Use relative URLs so `/Timed/` is retained. Do not use `/assets/...` or file-system
paths. Keep `Web/` next to `Fonts/` if using the delivered relative font URLs.
Apply `Web/brand.css` as a scoped reference, not a wholesale replacement that
breaks existing components or overrides accessibility styles.

If the website follows system theme, use `<picture>` with
`prefers-color-scheme`. If it offers a manual theme control, change both tokens
and asset sources from that explicit choice; a media query alone is insufficient.
Persist the choice only as the site’s current implementation requires. Avoid
unnecessary animation; respect reduced-motion preferences.

## Responsive and accessibility requirements
- At narrow widths, stack hero text and symbol. Do not squeeze a desktop banner.
- Use real HTML headings and body text; body at least 16 CSS pixels.
- Keep meaningful logo clear space, equal outer margins and matched baselines.
- Preserve 44px-or-larger interactive targets and visible keyboard focus.
- Give diagrams descriptive alt text; decorative duplicates use empty alt.
- Keep phase labels alongside color, and obey the supplied contrast pairings.
- Do not add glow effects, generic dashboards, fabricated screenshots or claims.

## Verification and delivery
Check home and guide at 360, 390, 768 and 1280px, in both themes and at 200% zoom.
Test keyboard navigation, TOC/skip/back-to-top links, release URLs, image/font
requests, favicons and social-card URLs beneath `/Timed/`. No page overflow.
Test logo masking and crossings in the browser, not just a design editor.

Preserve the repository’s docs-only release safeguards: a Pages-only change
must not trigger an app release or version bump. Native icon updates are a
separate app change; validate them with the platform-specific instructions.
Deliver focused changes with before/after screenshots of both pages and an
honest test report. Do not publish, merge, sign or submit to stores without approval.
