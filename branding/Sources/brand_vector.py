"""Self-contained SVG artwork with outlined type and matched PNG exports."""
import base64
import copy
import functools
import io
import json
import subprocess
import xml.etree.ElementTree as ET
from pathlib import Path

from fontTools.ttLib import TTFont
from fontTools.pens.svgPathPen import SVGPathPen
from fontTools.pens.boundsPen import BoundsPen
from PIL import Image, ImageFont, ImageOps
def font(*args, **kwargs):
    raise ValueError('Use a registered TimeIt static font')

ROOT = Path(__file__).resolve().parents[1]
NS = "http://www.w3.org/2000/svg"
XL = "http://www.w3.org/1999/xlink"
ET.register_namespace("", NS)
ET.register_namespace("xlink", XL)
FONTS = ROOT / "attached_assets/shopit-brand-directions/fonts"
MONO = Path("/usr/share/fonts/truetype/dejavu/DejaVuSansMono.ttf")
STATIC_FONTS = {}


@functools.lru_cache(None)
def face(family):
    return TTFont(STATIC_FONTS.get(family, MONO if family == "Mono" else FONTS / f"{family}.ttf"))


@functools.lru_cache(None)
def shaped(text, family, size, weight):
    f = face(family)
    location = {} if family in STATIC_FONTS else {"Fraunces": {"opsz": 72, "wght": weight, "SOFT": 0, "WONK": 0},
                "Manrope": {"wght": weight},
                "DMSans": {"opsz": min(size, 40), "wght": weight},
                "Mono": {}}[family]
    glyphs = f.getGlyphSet(location=location)
    cmap = f.getBestCmap()
    pil = ImageFont.truetype(str(STATIC_FONTS.get(family, MONO)), size) if family == "Mono" or family in STATIC_FONTS else font(family, size, weight)
    scale = size / f["head"].unitsPerEm
    result, boxes = [], []
    for i, char in enumerate(text):
        name = cmap.get(ord(char))
        if name is None:
            raise ValueError(f"Missing {char!r} in {family}")
        glyph = glyphs[name]
        pen, bounds = SVGPathPen(glyphs), BoundsPen(glyphs)
        glyph.draw(pen)
        glyph.draw(bounds)
        cursor = pil.getlength(text[:i+1]) - pil.getlength(char)
        if bounds.bounds:
            l, bottom, r, top = bounds.bounds
            boxes.append((cursor+l*scale, -top*scale, cursor+r*scale, -bottom*scale))
            result.append((cursor, pen.getCommands()))
    box = (min(p[0] for p in boxes), min(p[1] for p in boxes),
           max(p[2] for p in boxes), max(p[3] for p in boxes))
    return result, box, scale


class Canvas:
    def __init__(self, width, height, title, bg=None):
        self.width, self.height = width, height
        self.root = ET.Element(f"{{{NS}}}svg", {"width": str(width), "height": str(height),
            "viewBox": f"0 0 {width} {height}", "role": "img", "aria-label": title})
        ET.SubElement(self.root, f"{{{NS}}}title").text = title
        self.texts = []
        if bg:
            self.rect(0, 0, width, height, bg)

    def element(self, name, attrs, parent=None):
        return ET.SubElement(parent if parent is not None else self.root, f"{{{NS}}}{name}",
                             {k: str(v) for k, v in attrs.items()})

    def rect(self, x, y, w, h, fill="none", stroke=None, sw=1, radius=0):
        attrs = dict(x=x, y=y, width=w, height=h, fill=fill)
        if stroke:
            attrs.update(stroke=stroke, **{"stroke-width": sw})
        if radius:
            attrs["rx"] = radius
        self.element("rect", attrs)

    def line(self, x1, y1, x2, y2, color, sw=1):
        self.element("line", dict(x1=x1, y1=y1, x2=x2, y2=y2, stroke=color, **{"stroke-width": sw}))

    def arrow(self, x1, y, x2, color):
        self.line(x1, y, x2-10, y, color, 2)
        self.element("path", {"d": f"M{x2} {y}l-12 -7v14Z", "fill": color})

    def text(self, x, baseline, text, size, color, family="DMSans", weight=400, align="left", row=None):
        paths, bounds, scale = shaped(text, family, size, weight)
        offset = {"left": bounds[0], "right": bounds[2], "center": (bounds[0]+bounds[2])/2}[align]
        x -= offset
        box = [x+bounds[0], baseline+bounds[1], x+bounds[2], baseline+bounds[3]]
        assert box[0] >= -.01 and box[1] >= -.01 and box[2] <= self.width+.01 and box[3] <= self.height+.01, (text, box)
        g = self.element("g", {"fill": color, "aria-label": text})
        for advance, data in paths:
            self.element("path", {"d": data, "transform": f"translate({x+advance:.5f} {baseline}) scale({scale:.8f} {-scale:.8f})"}, g)
        self.texts.append({"text": text, "bounds": box, "baseline": baseline, "row": row})
        return box

    def centered(self, rect, text, size, color, family="DMSans", weight=400, align="center"):
        _, bounds, _ = shaped(text, family, size, weight)
        baseline = (rect[1]+rect[3]-bounds[1]-bounds[3])/2
        x = {"left": rect[0], "right": rect[2], "center": (rect[0]+rect[2])/2}[align]
        return self.text(x, baseline, text, size, color, family, weight, align)

    def image(self, path, x, y, width, height, center=(.5, .5)):
        im = ImageOps.exif_transpose(Image.open(path)).convert("RGB")
        im = ImageOps.fit(im, (round(width*2), round(height*2)), Image.Resampling.LANCZOS, centering=center)
        stream = io.BytesIO()
        im.save(stream, format="JPEG", quality=90)
        self.element("image", {"x": x, "y": y, "width": width, "height": height,
                              f"{{{XL}}}href": "data:image/jpeg;base64,"+base64.b64encode(stream.getvalue()).decode()})

    def symbol(self, app, x, y, height):
        base = ROOT / "generated-artifacts/apple-app-store-icons" / app / "sources"
        bbox = Image.open(base / "foreground-1024.png").getbbox()
        l, t, r, bot = bbox
        width = height*(r-l)/(bot-t)
        node = ET.parse(base / "foreground-1024.svg").getroot()
        node.attrib.update(x=str(x), y=str(y), width=str(width), height=str(height),
                           viewBox=f"{l} {t} {r-l} {bot-t}")
        self.root.append(node)
        return width

    def keyline(self, kind, x, y, size, color):
        path = ROOT / "attached_assets/shopit-graphics-pack/keyline-icons" / f"{kind}.svg"
        node = ET.parse(path).getroot()
        node.attrib.update(x=str(x), y=str(y), width=str(size), height=str(size), color=color)
        for child in node.iter():
            for key in ("fill", "stroke"):
                if child.get(key) == "currentColor":
                    child.set(key, color)
        self.root.append(node)

    def save(self, path, desc=""):
        path = Path(path)
        path.parent.mkdir(parents=True, exist_ok=True)
        ET.SubElement(self.root, f"{{{NS}}}desc").text = desc or self.root.get("aria-label")
        for row in {t["row"] for t in self.texts if t["row"]}:
            assert len({t["baseline"] for t in self.texts if t["row"] == row}) == 1
        for i, first in enumerate(self.texts):
            for second in self.texts[i+1:]:
                a, b = first["bounds"], second["bounds"]
                assert not (max(a[0], b[0]) < min(a[2], b[2]) and max(a[1], b[1]) < min(a[3], b[3])), (path.name, first["text"], second["text"])
        ET.ElementTree(self.root).write(path, encoding="utf-8", xml_declaration=True)
        subprocess.run(["magick", "-background", "none", str(path), "-colorspace", "sRGB", str(path.with_suffix(".png"))], check=True)
        with Image.open(path.with_suffix(".png")) as image:
            assert image.size == (self.width, self.height)
            image.verify()
        return {"file": path.name, "width": self.width, "height": self.height,
                "alt": desc or self.root.get("aria-label"), "text": self.texts}
