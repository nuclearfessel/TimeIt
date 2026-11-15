# iOS integration

The default icon is the dark full-bleed 1024px square master. It is opaque RGB
with an sRGB profile; do not pre-round it. iOS applies its own mask.

Replace only `app/ios/Runner/Assets.xcassets/AppIcon.appiconset/` with this
AppIcon.appiconset, including Contents.json. Do not replace the whole catalog.
Set/retain ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon in the Runner target.
The explicit phone, iPad compatibility and marketing slots support the existing
Flutter catalog layout; iPad slots do not announce a new supported product.

`timed-app-store-1024.png` is the marketing master. The optional light master
and transparent foreground are in ../Sources/. They are not automatically
registered appearance variants; make deliberate Xcode changes if adopting them.
This package does not contain a compiled Icon Composer `.icon` file.

On macOS run the project's normal Flutter/Xcode build, inspect Home Screen,
Settings and App Store archive icons, and validate the archive in Xcode.
Asset dimensions and alpha have been checked here, not Xcode/App Store acceptance.

Reference: https://developer.apple.com/design/human-interface-guidelines/app-icons
