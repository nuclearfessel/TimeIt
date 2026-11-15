# Handoff and implementation checks

## Export checks performed locally
- SVG XML parses; SVG/PNG pairs exist with matching dimensions.
- Lettering is vector paths, with no external font/image URLs.
- Text bounds/overlaps checked during export.
- README top/bottom alignment and equal 64px gaps checked.
- Horizontal/stacked/wordmark painted margins checked.
- iOS catalog slot dimensions and opaque RGB/sRGB icons checked.
- Android density sizes, XML references, monochrome silhouette and adaptive safe
  area checked. Play icon is 512×512 32-bit PNG below 1MB.
- Store feature graphics are 1024×500 RGB PNGs.
- ZIP CRC and individual file hashes checked.

See EXPORT-VALIDATION.json for actual counts and test results.

## Still required in the target app
- Flutter analyze/tests and release build.
- Xcode asset-catalog/archive validation and real iOS install.
- Android adaptive masks, API 33+ themed icons and a real APK/AAB install.
- Store-console acceptance and authentic screenshot production.
- README/site rendering at real deployed paths and phone widths.

Local asset checks and illustrative mask previews are not device or store tests.
