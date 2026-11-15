import json, hashlib, zipfile
import xml.etree.ElementTree as ET
from pathlib import Path
from PIL import Image, ImageCms
OUT=Path(__file__).resolve().parents[1]

def write(name,text):
    path=OUT/name;path.parent.mkdir(parents=True,exist_ok=True)
    path.write_text(text.strip()+"\n")

def validate():
    counts={"svg":0,"png":0,"ios_slots":0}
    for path in OUT.rglob("*.svg"):
        root=ET.parse(path).getroot();counts["svg"]+=1
        assert not root.findall(".//{http://www.w3.org/2000/svg}text"),path
        assert not root.findall(".//{http://www.w3.org/2000/svg}image"),path
        assert path.with_suffix(".png").exists(),path
        with Image.open(path.with_suffix(".png")) as im:
            assert im.size==(int(root.get("width")),int(root.get("height"))),path
    for path in OUT.rglob("*.png"):
        with Image.open(path) as im:im.verify()
        counts["png"]+=1
    for path in (OUT/"Brand").glob("*.png"):
        im=Image.open(path).convert("RGBA");b=im.getbbox()
        assert im.getpixel((0,0))[3]==0,path
        assert abs(b[0]-(im.width-b[2]))<=2,(path,b,im.size)
        assert abs(b[1]-(im.height-b[3]))<=2,(path,b,im.size)
    catalog=OUT/"AppIcons/iOS/Assets.xcassets/AppIcon.appiconset"
    for item in json.loads((catalog/"Contents.json").read_text())["images"]:
        counts["ios_slots"]+=1
        with Image.open(catalog/item["filename"]) as im:
            size=round(float(item["size"].split("x")[0])*int(item["scale"][0]))
            assert im.size==(size,size) and im.mode=="RGB"
            assert im.info.get("icc_profile")
    assert counts["ios_slots"]==18
    android=OUT/"AppIcons/Android"
    for path in android.rglob("*.xml"):
        root=ET.parse(path).getroot()
        for node in root.iter():
            for value in node.attrib.values():
                if value.startswith(("@drawable/","@mipmap/")):
                    resource_type,name=value[1:].split("/",1)
                    assert any(android.glob(f"res/{resource_type}*/{name}.*")),(path,value)
                elif value.startswith("@color/"):
                    colors=ET.parse(android/"res/values/timeit_launcher_colors.xml").getroot()
                    assert any(c.get("name")==value.split("/",1)[1] for c in colors),(path,value)
    for name,size in (("mdpi",48),("hdpi",72),("xhdpi",96),("xxhdpi",144),("xxxhdpi",192)):
        assert Image.open(android/"res"/f"mipmap-{name}/ic_launcher.png").size==(size,size)
    for density,size in (("mdpi",108),("hdpi",162),("xhdpi",216),("xxhdpi",324),("xxxhdpi",432)):
        layers=[Image.open(android/"res"/f"mipmap-{density}/{name}.png").convert("RGBA")
                for name in ("timeit_launcher_foreground","timeit_launcher_monochrome")]
        assert all(im.size==(size,size) for im in layers)
        assert layers[0].getchannel("A").tobytes()==layers[1].getchannel("A").tobytes()
    fg=Image.open(android/"AdaptiveLayers/foreground-432.png").convert("RGBA")
    mono=Image.open(android/"AdaptiveLayers/monochrome-432.png").convert("RGBA")
    assert fg.getchannel("A").tobytes()==mono.getchannel("A").tobytes()
    for y in range(432):
        for x in range(432):
            if fg.getpixel((x,y))[3]>10:
                assert (x-215.5)**2+(y-215.5)**2 <=132**2
                assert mono.getpixel((x,y))[:3]==(255,255,255)
    with Image.open(android/"GooglePlay/timeit-play-store-512.png") as im:
        assert im.size==(512,512) and im.mode=="RGBA" and im.getchannel("A").getextrema()==(255,255)
    for p in (OUT/"Store").glob("*.png"):
        im=Image.open(p).convert("RGB")
        assert im.size==(1024,500)
        im.save(p,icc_profile=ImageCms.ImageCmsProfile(ImageCms.createProfile("sRGB")).tobytes())
    counts.update({"text_layout":"passed at export","logo_transparency_and_centering":"passed",
                   "native_icon_resource_checks":"passed","android_safe_circle":"passed",
                   "native_build_and_store_validation":"not performed"})
    write("Instructions/EXPORT-VALIDATION.json",json.dumps(counts,indent=2))
    return counts

if __name__=='__main__':
    print(validate())
