"""Mobile-only TimeIt native icons, with inspectable vector sources."""
import json
import math
import xml.etree.ElementTree as ET
from PIL import Image, ImageCms, ImageDraw, ImageFont
from build_timeit_graphics import OUT, Canvas, mark, STATIC_FONTS, MARK_RATIO

ICC=ImageCms.ImageCmsProfile(ImageCms.createProfile("sRGB")).tobytes()
A="http://schemas.android.com/apk/res/android"
ET.register_namespace("android",A)
BACKGROUND="#0B0B0C"


def write(path,content):
    path.parent.mkdir(parents=True,exist_ok=True)
    path.write_text(content.strip()+"\n")


def xml(root,path):
    path.parent.mkdir(parents=True,exist_ok=True)
    ET.ElementTree(root).write(path,encoding="utf-8",xml_declaration=True)


def png(im,path,size,mode="RGB"):
    path.parent.mkdir(parents=True,exist_ok=True)
    im.resize((size,size),Image.Resampling.LANCZOS).convert(mode).save(path,icc_profile=ICC)


def masters():
    for mode,bg in (("dark",BACKGROUND),("light","#F7F6F3")):
        c=Canvas(1024,1024,f"TimeIt {mode} app icon",bg)
        w=700;h=w*MARK_RATIO
        mark(c,(1024-w)/2,(1024-h)/2,w,small=True)
        path=OUT/"AppIcons/Sources"/f"timeit-app-icon-{mode}-1024.svg"
        c.save(path,"Opaque unmasked TimeIt app icon, derived from the approved Interlocking Lanes mark. System applies the mask.")
        im=Image.open(path.with_suffix(".png")).convert("RGB")
        png(im,path.with_suffix(".png"),1024)
    # Transparent authoring mark; not an App Store upload.
    c=Canvas(1024,1024,"TimeIt icon foreground")
    mark(c,162,(1024-700*MARK_RATIO)/2,700,small=True)
    c.save(OUT/"AppIcons/Sources/timeit-icon-foreground.svg","Transparent foreground authoring layer, not a compiled Icon Composer file.")
    return Image.open(OUT/"AppIcons/Sources/timeit-app-icon-dark-1024.png").convert("RGB")


def ios(master):
    root=OUT/"AppIcons/iOS/Assets.xcassets"
    iconset=root/"AppIcon.appiconset"
    write(root/"Contents.json",json.dumps({"info":{"author":"xcode","version":1}},indent=2))
    slots=[]
    specs=[("iphone",s,k) for s in (20,29,40,60) for k in (2,3)]
    specs +=[("ipad",s,k) for s in (20,29,40,76) for k in (1,2)]
    specs +=[("ipad",83.5,2),("ios-marketing",1024,1)]
    for idiom,size,scale in specs:
        name=f"icon-{idiom}-{size:g}@{scale}x.png"
        png(master,iconset/name,round(size*scale))
        slots.append({"idiom":idiom,"size":f"{size:g}x{size:g}","scale":f"{scale}x","filename":name})
    write(iconset/"Contents.json",json.dumps({"images":slots,"info":{"author":"xcode","version":1}},indent=2))
    png(master,OUT/"AppIcons/iOS/timeit-app-store-1024.png",1024)
    write(OUT/"AppIcons/iOS/README.md","""
# iOS integration

The default icon is the dark full-bleed 1024px square master. It is opaque RGB
with an sRGB profile; do not pre-round it. iOS applies its own mask.

Replace only `app/ios/Runner/Assets.xcassets/AppIcon.appiconset/` with this
AppIcon.appiconset, including Contents.json. Do not replace the whole catalog.
Set/retain ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon in the Runner target.
The explicit phone, iPad compatibility and marketing slots support the existing
Flutter catalog layout; iPad slots do not announce a new supported product.

`timeit-app-store-1024.png` is the marketing master. The optional light master
and transparent foreground are in ../Sources/. They are not automatically
registered appearance variants; make deliberate Xcode changes if adopting them.
This package does not contain a compiled Icon Composer `.icon` file.

On macOS run the project's normal Flutter/Xcode build, inspect Home Screen,
Settings and App Store archive icons, and validate the archive in Xcode.
Asset dimensions and alpha have been checked here, not Xcode/App Store acceptance.

Reference: https://developer.apple.com/design/human-interface-guidelines/app-icons
""")


def android(master):
    root=OUT/"AppIcons/Android"
    # True 32-bit RGBA PNG, with an entirely opaque alpha channel.
    png(master,root/"GooglePlay/timeit-play-store-512.png",512,"RGBA")
    assert (root/"GooglePlay/timeit-play-store-512.png").stat().st_size<1024*1024
    for density,size in (("mdpi",48),("hdpi",72),("xhdpi",96),("xxhdpi",144),("xxxhdpi",192)):
        png(master,root/"res"/f"mipmap-{density}"/"ic_launcher.png",size)
        round_im=master.convert("RGBA")
        mask=Image.new("L",(1024,1024),0)
        ImageDraw.Draw(mask).ellipse((0,0,1023,1023),fill=255)
        round_im.putalpha(mask)
        png(round_im,root/"res"/f"mipmap-{density}"/"ic_launcher_round.png",size,"RGBA")
    # Preserve the exact woven knockouts. Adaptive icons support transparent
    # raster layers; SVG masks cannot be copied into VectorDrawable pathData.
    for name in ("timeit_launcher_foreground","timeit_launcher_monochrome"):
        (root/"res/drawable"/f"{name}.xml").unlink(missing_ok=True)
    resources=ET.Element("resources")
    ET.SubElement(resources,"color",{"name":"timeit_launcher_background"}).text=BACKGROUND
    xml(resources,root/"res/values/timeit_launcher_colors.xml")
    for version,mono in ((26,False),(33,True)):
        adaptive=ET.Element("adaptive-icon")
        ET.SubElement(adaptive,"background",{f"{{{A}}}drawable":"@color/timeit_launcher_background"})
        ET.SubElement(adaptive,"foreground",{f"{{{A}}}drawable":"@mipmap/timeit_launcher_foreground"})
        if mono:ET.SubElement(adaptive,"monochrome",{f"{{{A}}}drawable":"@mipmap/timeit_launcher_monochrome"})
        for name in ("ic_launcher","ic_launcher_round"):
            xml(adaptive,root/"res"/f"mipmap-anydpi-v{version}"/f"{name}.xml")
    for mono in (False,True):
        c=Canvas(432,432,"TimeIt adaptive authoring layer")
        w=208;h=w*MARK_RATIO
        mark(c,(432-w)/2,(432-h)/2,w,"#FFFFFF" if mono else None,small=True)
        c.save(root/"AdaptiveLayers"/f"{'monochrome' if mono else 'foreground'}-432.svg",
               "108dp adaptive authoring layer at 4x, centered within the safe area.")
        layer=Image.open(root/"AdaptiveLayers"/f"{'monochrome' if mono else 'foreground'}-432.png").convert("RGBA")
        if mono:
            white=Image.new("RGBA",layer.size,"white")
            white.putalpha(layer.getchannel("A"))
            layer=white
            layer.save(root/"AdaptiveLayers/monochrome-432.png")
        resource="timeit_launcher_monochrome" if mono else "timeit_launcher_foreground"
        for density,size in (("mdpi",108),("hdpi",162),("xhdpi",216),("xxhdpi",324),("xxxhdpi",432)):
            png(layer,root/"res"/f"mipmap-{density}"/f"{resource}.png",size,"RGBA")
    write(root/"README.md","""
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
- GooglePlay/timeit-play-store-512.png is the full-square 32-bit sRGB listing
  icon, below 1MB. Let Play apply rounding and shadow.

Use a compile SDK supporting API 33 resources; inspect the existing Flutter
configuration before making any toolchain change. Build and install the release
APK/AAB and test circular/squircle masks, small launcher sizes, and Android 13+
themed icons. Preview masks in this package are illustrative, not emulator tests.

References:
- https://developer.android.com/develop/ui/compose/system/icon_design_adaptive
- https://developer.android.com/distribute/google-play/resources/icon-design-specifications
""")


def preview(master):
    im=Image.new("RGB",(1400,720),"#F7F6F3");d=ImageDraw.Draw(im)
    f=ImageFont.truetype(str(STATIC_FONTS["JakartaBold"]),26)
    d.text((48,30),"TimeIt / app icon family",font=f,fill="#161618")
    for x,label,kind in [(60,"Unmasked store master","square"),(500,"System mask preview","round"),(940,"Android themed preview","mono")]:
        tile=master.resize((320,320),Image.Resampling.LANCZOS).convert("RGBA")
        if kind=="round":
            mask=Image.new("L",(320,320),0);ImageDraw.Draw(mask).rounded_rectangle((0,0,319,319),radius=72,fill=255);tile.putalpha(mask)
        if kind=="mono":
            fg=Image.open(OUT/"AppIcons/Android/AdaptiveLayers/monochrome-432.png").convert("RGBA")
            tile=Image.new("RGBA",(320,320),"#244C43")
            # Approximate the system's central 72dp viewport, not the 108dp source.
            fg=fg.crop((72,72,360,360)).resize((320,320),Image.Resampling.LANCZOS)
            tile.alpha_composite(fg)
            mask=Image.new("L",(320,320),0);ImageDraw.Draw(mask).ellipse((0,0,319,319),fill=255);tile.putalpha(mask)
        im.paste(tile,(x,132),tile)
        d.text((x,486),label,font=f,fill="#161618")
    d.text((60,596),"24px",font=f,fill="#161618")
    for i,size in enumerate((24,32,48,64)):
        tile=master.resize((size,size),Image.Resampling.LANCZOS)
        im.paste(tile,(180+i*100,580))
    d.text((720,596),"Woven symbol. No embedded text.",font=f,fill="#161618")
    im.save(OUT/"Previews/app-icon-family.png")


if __name__=="__main__":
    master=masters();ios(master);android(master);preview(master)
    print("TimeIt iOS catalog, Android resources and store masters generated.",flush=True)
