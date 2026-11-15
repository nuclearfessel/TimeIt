# Timed branding

## Identity
The mark is the approved Interlocking Lanes symbol, with three capsule tracks
and six crossings. Each pair changes which lane is above at its two crossings.
The official orientation is the approved 180-degree clockwise rotation:
the triangle points upward, with the green lane along the bottom.
All supplied assets already use this orientation. Do not rotate them again.
It represents linked standby, work and rest phases. Preserve the transparent
crossing gaps in color and monochrome exports; never flatten them to a background color.
Do not turn it into a clock face or borrow either other app's symbol.

## Typography
- Hepta Slab SemiBold (600): Timed wordmark, large headlines and timer digits.
- Plus Jakarta Sans Regular (400): descriptions and supporting copy.
- Plus Jakarta Sans Bold (700): phase labels, metadata and short navigation.
- Preserve actual glyph alignment. Do not use font line boxes or guess top offsets.
- Outlined logos have balanced visible margins. Do not add one-sided CSS padding.

## Color
Standby #009E73; Work #D55E00; Rest #0072B2. Preserve these meanings.
Use near-black #060909 on green and orange, white #FFFFFF on blue.
White on the orange is not the normal-text pairing for these assets.
See Web/design-tokens.json and Instructions/CONTRAST-CHECK.json.

Dark marketing: #0B0B0C background, #161618 surface, #F4F4EF text.
Light marketing: #F7F6F3 background, #FFFFFF surface, #161618 text.
These are marketing tokens. Do not silently rewrite Flutter's current theme,
which has its own approved light/dark values and currently uses #F4F4F5 dark text.

## Geometry and placement
- README content edges: x=72 and x=1528 on the 1600px canvas.
- Header rule y=100; title/track bounds y=164..460; phase bands begin y=524.
  This yields equal 64px gaps above and below the complete header block.
- Symbol right edge aligns with the content right edge.
- “Timed” aligns with the symbol's top; the separate tagline aligns with its bottom.
- Do not put “READY. WORK. RECOVER.” or any other text inside the symbol.
- Phase numbers, labels, details and digits share each band's visual center.
- Minimum logo clear space: one outer-lane thickness; use more where possible.
- Retain the supplied padded exports. Scale uniformly; never stretch curves.
- Do not add gradients, drop shadows, decorative glows or unrelated illustrations.

## Small-size icon adaptation
The app icon uses the exact approved woven symbol without text.
Use the app-icon masters, not a shrunk screenshot of the full banner.
Colored, monochrome and grayscale marks are supplied. White marks require a
dark background; black marks require a light background.
On the site's colored header gradients use Web/header-logo-on-color.svg,
which has an intentional light protective plate. Do not put the three-color
symbol directly over a matching green/orange/blue band: a lane may disappear.
Use the bare transparent marks on neutral surfaces. The tagline is optional:
omit it below a 380px-wide tagline lockup rather than shrinking it to illegibility.

## Voice and examples
Direct, energetic and personal; never prescriptive or competitive.
- Headline: “Make every interval yours.”
- Intro: “Build a timer around the way you train.”
- Empty state: “Your next routine starts here. Create a timer.”
- Action: “Create timer.”
- Error: “Couldn't save this timer. Try again.”
These are copy proposals, not permission to alter app behavior.

## Accessibility
Keep phase words visible; color must not be the only signal. Use body text
at least 16 CSS px and captions at least 12px in live layouts. Complex image
diagrams need equivalent nearby text; don't shrink a large SVG until labels
become unreadable. Use semantic headings, visible keyboard focus and useful alt
text. Keep targets at least 44pt on iOS and 48dp on Android.
Motion is not part of this handoff; any future decoration must respect reduced
motion. Never claim lock-screen/background cue reliability without device tests.
