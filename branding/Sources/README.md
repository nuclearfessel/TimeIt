# Regeneration sources
These generators work within this Timed directory. Install Python requirements
and ImageMagick (`magick` command) using your environment's normal package tools.
Run from Sources:
```
python build_timed_graphics.py
python build_timed_icons.py
python validate_assets.py
python repack.py
```
They regenerate SVG/PNG artwork and icon resources, not app source or websites.
Read the branding rules first. Do not replace reviewed art accidentally.
The last two commands validate the assets and refresh the manifest/ZIP beside
the Timed directory. They overwrite that generated ZIP, not any app code.
The existing manifest records the delivered files and is stale after any edits.
