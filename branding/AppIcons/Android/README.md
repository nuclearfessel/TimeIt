# Android integration

Merge the supplied `res/` files into `app/android/app/src/main/res/`.
Do not replace that whole directory. Retain unrelated resources and package IDs.
Update/verify the application attributes in the existing AndroidManifest.xml:

```xml
android:icon="@mipmap/ic_launcher"
android:roundIcon="@mipmap/ic_launcher_round"
```

- Legacy launchers: mdpi through xxxhdpi PNGs; round variants are explicitly
  masked only for legacy launchers, never for store uploads/adaptive sources.
- API 26+: adaptive XML with separate background and transparent PNG foreground.
- API 33+: adaptive XML also references the white monochrome PNG layer.
- The layers use a 108dp canvas at each Android density. The 52dp-wide mark is centered and wholly
  inside the central 66dp safe circle, including its corners.
- AdaptiveLayers/ supplies transparent SVG/PNG authoring copies; Android uses
  the density-specific PNGs via mipmap references. This preserves the actual
  transparent over-under crossings; do not convert SVG masks to plain vector paths.
- GooglePlay/timed-play-store-512.png is the full-square 32-bit sRGB listing
  icon, below 1MB. Let Play apply rounding and shadow.

Use a compile SDK supporting API 33 resources; inspect the existing Flutter
configuration before making any toolchain change. Build and install the release
APK/AAB and test circular/squircle masks, small launcher sizes, and Android 13+
themed icons. Preview masks in this package are illustrative, not emulator tests.

References:
- https://developer.android.com/develop/ui/compose/system/icon_design_adaptive
- https://developer.android.com/distribute/google-play/resources/icon-design-specifications
