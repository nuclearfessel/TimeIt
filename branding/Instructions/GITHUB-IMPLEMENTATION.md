# Other-agent implementation brief — Timed

Repository: https://github.com/nuclearfessel/Timed
Reviewed on 2026-11-14. Re-read the current source before editing; it is changing.

## Boundaries
Implement only Timed branding. The Flutter app lives in `app/`.
Preserve timer behavior, stored routines, IDs, versions, signing and dependencies.
Do not add desktop/Watch support, Pomodoro, preset exercises, payments or analytics.
No publishing, release, merge or store submission without the owner's approval.

## 1. Inspect the repository
Read README.md and AGENTS.md, inspect the actual branch/worktree, then create a
focused branding branch under the repository's current conventions.
Inspect app/pubspec.yaml, app/lib/theme/app_theme.dart, the iOS icon catalog,
AndroidManifest.xml and resources. Record existing brand references with search.
Keep research docs and the reference board; it contains third-party references,
not licensed marketing assets to redistribute.

The app already has HeptaSlab and PlusJakartaSans families configured. Do not
replace that registration or delete other weights. Bundled fonts here are the
three weights used in these graphics.

## 2. Place the artwork
Recommended repository mapping:
```
branding/Brand/          <- Brand/
branding/Graphics/       <- Graphics/
branding/Store/          <- Store/
branding/Fonts/          <- Fonts/
branding/Licenses/       <- Licenses/
branding/Web/            <- Web/
branding/Instructions/   <- Instructions/
```
Preserve filename case and directory relationships. Store native icon resources
in the actual app paths described in AppIcons/iOS/README.md and
AppIcons/Android/README.md, not merely in an unused branding folder.
Keep source masters and the brand guide in the repository; do not commit the ZIP.

## 3. README and documentation
Replace/add the README banner using README-USAGE.md. Document simple timers,
advanced stacks and phase colors with the matching themed SVGs.
Use text alongside diagrams, not diagrams as the only instructions.
Do not describe the graphics as screenshots. No sample durations imply
mandatory exercise presets.

## 4. App branding
- Integrate the supplied native icons following the platform-specific READMEs.
- If adding an in-app vector logo, inspect the app's existing asset/rendering
  approach first. Flutter does not render an arbitrary SVG via Image.asset.
  Use the PNG assets at appropriate resolutions or an existing SVG renderer;
  do not add a package silently just to show a logo.
- Update app/assets and the pubspec assets section only when the app actually
  uses those images. Do not bundle all documentation images inside the binary.
- Preserve existing phase colors. Marketing light/dark exports do not authorize
  a functional or visual overhaul of app screens.

## 5. GitHub Pages home and guide — requested scope
Read WEBSITE-REVAMP.md for the page-by-page plan and colored-header rules.
Update docs/index.html and docs/guide.html with the same inspection,
content-preservation and responsive-verification methodology as the sibling apps.
Both live pages and their shared CSS were inspected for this handoff.
The `reference/index.html` file is a research board, not a production home page.
Do not overwrite it to create a marketing site.

## 6. Verify
From app/, use the repository's installed Flutter toolchain:
```
flutter analyze
flutter test
flutter build apk --release
```
Use its existing iOS/Xcode build process on macOS, with the owner's signing.
Test installed launcher icons on Android and iOS, not just PNG previews.
Inspect light/dark README rendering, linked SVGs, mobile widths and font licenses.
Smoke-test create/edit/delete, simple/advanced runs, pause/resume and sounds to
confirm branding changes did not change behavior.

Deliver a focused PR with changed paths, screenshots and test results. Clearly
separate completed checks from any checks blocked by signing or device access.
