# Logos on the current GitHub Pages header colors
Use `header-logo-on-color.svg` on both the home and guide colored headers.
The plate is intentionally opaque light neutral; the artwork's woven crossing
gaps remain transparent over that plate. This avoids same-color lane loss and
keeps the dark wordmark readable on every supplied gradient.

```html
<a class="timed-header-brand" href="./" aria-label="Timed home">
  <img src="assets/timed/Web/header-logo-on-color.svg" alt="Timed">
</a>
```
```css
.timed-header-brand { display:inline-flex; flex-shrink:0; }
.timed-header-brand img { display:block; height:48px; width:auto; max-width:100%; }
```
Keep the same header sizing on home and guide; adjust both together if needed.
The plate already includes clear space: do not add one-sided padding.
Do not invert/filter this image in dark mode or set opacity below 1.
Use `Brand/timed-horizontal-light.svg` on neutral light sections and
`Brand/timed-horizontal-dark.svg` on neutral dark sections instead.
Do not assume a white wordmark passes normal-text contrast on all bright phase bands.

Inspected site gradient stops:
- Green: #0F3D32 to #009E73.
- Orange: #8A3C00 to #D55E00 (55%) to #B34A00.
- Blue: #0072B2 to #024A73.

See `Previews/colored-header-proof.png` for all three actual gradient ranges.
