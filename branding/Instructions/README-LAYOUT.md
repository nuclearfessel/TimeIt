# TimeIt README graphics — placement and embeds

The full set is in `Graphics/`, in light/dark SVG and PNG pairs. Open `Previews/readme-graphics-light.png` or `readme-graphics-dark.png` to review it.

The following is a copy-ready layout for the **repository-root README** after the package is installed under `branding/`. Merge it into the existing README; retain setup, research, contribution, license and other useful existing content. These relative paths are intentionally for the target README, not this instruction file.

Use banner + features + workflow as a compact core. The remaining panels provide a fuller README or may support the corresponding guide sections. Social cards are for sharing metadata, not another repeated README hero.

**Illustrations, not screenshots:** the phone and control drawings explain the product; do not caption them as the exact current app interface. No store availability, native theme behavior or unimplemented sound preferences are implied.

## TimeIt

A workout interval timer with simple rounds or advanced stacks of standby, work and rest.

```html
<picture>
  <source media="(prefers-color-scheme: dark)"
          srcset="branding/Graphics/readme-banner-dark.svg">
  <img src="branding/Graphics/readme-banner-light.svg"
       alt="TimeIt: make every interval yours. A workout interval timer for iOS and Android." width="1600">
</picture>
```

## Your session at a glance

Clear phase labels and countdown digits help you follow the session. The illustrated durations are examples, not preset workouts.

```html
<picture>
  <source media="(prefers-color-scheme: dark)"
          srcset="branding/Graphics/session-overview-dark.svg">
  <img src="branding/Graphics/session-overview-light.svg"
       alt="Illustrated standby, work and rest phases with a conceptual timer screen, not a screenshot." width="1600">
</picture>
```

## Features

Create your own timers and sets. Choose simple rounds or build a custom sequence, then edit or delete routines as needed.

```html
<picture>
  <source media="(prefers-color-scheme: dark)"
          srcset="branding/Graphics/features-dark.svg">
  <img src="branding/Graphics/features-light.svg"
       alt="Simple timers, advanced stacks and user-created routines." width="1600">
</picture>
```

## Getting started

Choose Simple or Advanced, configure the timer and start. See the [guide](https://nuclearfessel.github.io/TimeIt/guide.html) for full instructions.

```html
<picture>
  <source media="(prefers-color-scheme: dark)"
          srcset="branding/Graphics/workflow-dark.svg">
  <img src="branding/Graphics/workflow-light.svg"
       alt="Choose a format, build your routine, then start the session." width="1600">
</picture>
```

## Two timer formats

Simple timers run standby once, followed by work/rest rounds, with no rest after the final work interval. Advanced timers repeat a custom phase sequence in cycles.

```html
<picture>
  <source media="(prefers-color-scheme: dark)"
          srcset="branding/Graphics/timer-types-dark.svg">
  <img src="branding/Graphics/timer-types-light.svg"
       alt="Simple rounds compared with flexible advanced phase stacks." width="1600">
</picture>
```

## Phase cues

Phase labels and sounds accompany the color cues; meaning does not depend on color alone.

```html
<picture>
  <source media="(prefers-color-scheme: dark)"
          srcset="branding/Graphics/phases-dark.svg">
  <img src="branding/Graphics/phases-light.svg"
       alt="Green standby, orange work and blue rest, each identified with text." width="1600">
</picture>
```

## Run controls

Start a session, pause and resume it, skip to the next phase or reset to the first phase.

```html
<picture>
  <source media="(prefers-color-scheme: dark)"
          srcset="branding/Graphics/run-controls-dark.svg">
  <img src="branding/Graphics/run-controls-light.svg"
       alt="Start, Pause/Resume, Skip and Reset explained through an illustrated control diagram." width="1600">
</picture>
```

## Mobile platforms

TimeIt targets iOS and Android. Check [GitHub Releases](https://github.com/nuclearfessel/TimeIt/releases) and the [installation guide](https://nuclearfessel.github.io/TimeIt/guide.html#install) for current packages. iOS distribution requires signing on a Mac.

```html
<picture>
  <source media="(prefers-color-scheme: dark)"
          srcset="branding/Graphics/mobile-platforms-dark.svg">
  <img src="branding/Graphics/mobile-platforms-light.svg"
       alt="Conceptual iOS and Android devices, not app screenshots or store badges." width="1600">
</picture>
```

## Implementation checks

- Keep the text paragraphs beside the images for accessibility and search.
- Use the PNG with the same basename where SVG is unsupported.
- Keep natural aspect ratios; never stretch or crop text-bearing graphics.
- Verify light/dark GitHub rendering and asset links from the actual README.
- For GitHub Pages, use docs/assets/timeit/ paths and the separate website brief.
- Keep the app logos and colored-header protected logo unchanged.
