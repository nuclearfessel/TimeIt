# Graphics usage

Assuming the package directories are installed under repository-root `branding/`:

```html
<picture>
  <source media="(prefers-color-scheme: dark)"
          srcset="branding/Graphics/readme-banner-dark.svg">
  <img src="branding/Graphics/readme-banner-light.svg"
       alt="Timed: create your own standby, work and rest interval routines."
       width="1600" height="1158">
</picture>
```

Use matching `features-{theme}.svg`, `workflow-{theme}.svg`,
`phases-{theme}.svg` and `timer-types-{theme}.svg` near their relevant prose.
Graphics/text-and-alt-inventory.json lists dimensions, lettering and alt text.
PNG alternatives have the same base filenames and composition.

Website images: `max-width:100%;height:auto`. Never stretch width and height
independently. Use relative URLs under the deployed project prefix.
System-theme `<picture>` does not automatically follow a custom manual theme
toggle; update image sources when the site uses an explicit theme choice.

Use transparent Brand/timed-horizontal-light.svg on a light surface and
timed-horizontal-dark.svg on a dark surface. For small badges use the mark alone.
Use the 1200×630 PNG social cards for Open Graph previews after verifying an
actual published absolute URL. No production URL is supplied or invented.

Store/google-play-feature-*.png are 1024×500 feature graphics. They are not
App Store screenshots. Capture authentic current UI for store screenshot slots;
do not submit these illustrations as screenshots.
