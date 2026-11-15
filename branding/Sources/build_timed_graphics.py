"""Approved Interval Score artwork, outlined SVG type and paired PNGs."""
import json
import shutil
import copy
import sys
import subprocess
import xml.etree.ElementTree as ET
from pathlib import Path
from PIL import Image, ImageDraw, ImageFont
from fontTools.ttLib import TTFont
from brand_vector import Canvas, shaped, STATIC_FONTS, ROOT

OUT=ROOT
SOURCE=ROOT
GREEN,ORANGE,BLUE="#009E73","#D55E00","#0072B2"
COLORS=(GREEN,ORANGE,BLUE)
INVENTORY=[]
MARK_RATIO=353/384
for short,name in (("Hepta","HeptaSlab-SemiBold"),("Jakarta","PlusJakartaSans-Regular"),("JakartaBold","PlusJakartaSans-Bold")):
    STATIC_FONTS[short]=SOURCE/"Fonts"/f"{name}.ttf"


def theme(mode):
    return dict(zip(("bg","surface","ink","muted","line"),
        ("#0B0B0C","#161618","#F4F4EF","#A8A8AE","#343438") if mode=="dark" else
        ("#F7F6F3","#FFFFFF","#161618","#61616B","#C6C3BC")))


def t(c,x,cy,value,size,color,family="Jakarta",align="left",top=None,bottom=None):
    _,b,_=shaped(value,family,size,400)
    baseline=cy-(b[1]+b[3])/2
    if top is not None:baseline=top-b[1]
    if bottom is not None:baseline=bottom-b[3]
    return c.text(x,baseline,value,size,color,family,align=align)


def save(c,folder,name,alt):
    record=c.save(OUT/folder/f"{name}.svg",alt)
    if folder=="Brand":
        bounds=Image.open(OUT/folder/f"{name}.png").convert("RGBA").getchannel("A").getbbox()
        l,top,r,b= bounds
        dx,dy=32-l,32-top
        children=list(c.root)
        group=c.element("g",{"transform":f"translate({dx} {dy})"})
        for node in children:
            if node.tag.rsplit("}",1)[-1] not in ("title","desc"):
                c.root.remove(node);group.append(node)
        c.width,c.height=r-l+64,b-top+64
        c.root.set("width",str(c.width));c.root.set("height",str(c.height))
        c.root.set("viewBox",f"0 0 {c.width} {c.height}")
        for item in c.texts:
            box=item["bounds"]
            item["bounds"]=[box[0]+dx,box[1]+dy,box[2]+dx,box[3]+dy]
        record=c.save(OUT/folder/f"{name}.svg",alt)
    record["file"]=f"{folder}/{record['file']}"
    INVENTORY.append(record)


def lane_path(left,cx,cy,r,stroke):
    inner=r-stroke
    return (f"M{left} {cy-r}H{cx}A{r} {r} 0 0 1 {cx} {cy+r}H{left}"
            f"V{cy+inner}H{cx}A{inner} {inner} 0 0 0 {cx} {cy-inner}H{left}Z")


def mark(c,x,y,width,mono=None,small=False):
    """Use the approved, truly interwoven master at every size."""
    variant="white" if mono and mono.upper() in ("#FFFFFF","#F4F4EF","#F7F6F3") else "black" if mono else "color"
    node=ET.parse(OUT/"Sources/Symbols"/f"symbol-{variant}.svg").getroot()
    height=width*MARK_RATIO
    node.attrib.update(x=str(x),y=str(y),width=str(width),height=str(height),
                       viewBox="64 79 384 353")
    prefix=f"symbol-{len(list(c.root))}-"
    ids={el.get("id"):prefix+el.get("id") for el in node.iter() if el.get("id")}
    for el in node.iter():
        if el.get("id"):el.set("id",ids[el.get("id")])
        for key,value in list(el.attrib.items()):
            for old,new in ids.items():value=value.replace(f"url(#{old})",f"url(#{new})")
            el.set(key,value)
        if mono and el.get("fill") in ("#161618","#F7F6F3"):
            el.set("fill",mono)
    c.root.append(node)
    return height


def track(c,left,cx,cy,p):
    for radius,col in zip((148,115,82),COLORS):
        c.element("path",{"d":lane_path(left,cx,cy,radius,12),"fill":col})
        c.rect(left-18,cy+radius-12,6,12,col)
    caption_x=(left+cx+82-12)/2
    t(c,caption_x,cy,"READY. WORK. RECOVER.",16,p["ink"],"JakartaBold","center")


def panel(c,x,y,w,h,col):
    c.element("path",{"d":f"M{x} {y}H{x+w-20}L{x+w} {y+20}V{y+h}H{x+20}L{x} {y+h-20}Z","fill":col})


def masthead(c,p,label,width=1600):
    mark(c,72,46,44)
    t(c,134,66,label,17,p["ink"],"JakartaBold")
    t(c,width-72,66,"iOS / ANDROID",17,p["ink"],"JakartaBold","right")
    c.line(72,100,width-72,100,p["line"])


def hero(mode):
    p=theme(mode);c=Canvas(1600,1158,f"Timed README banner ({mode})",p["bg"])
    masthead(c,p,"INTERVAL TRAINING, ON YOUR TERMS.")
    title=t(c,72,226,"Timed",154,p["ink"],"Hepta",top=164)
    c.rect(77,326,98,6,ORANGE)
    tag=t(c,72,436.5,"Make every interval yours.",47,p["ink"],"Hepta",bottom=460)
    logo_width=296/MARK_RATIO
    mark(c,1528-logo_width,164,logo_width)
    assert abs(title[1]-164)<.01 and abs(tag[3]-460)<.01 and 164-100==524-460
    phases=[("01","STANDBY","Find your position.","00:10",GREEN),
            ("02","WORK","Make this interval count.","00:45",ORANGE),
            ("03","REST","Breathe. Reset. Go again.","00:15",BLUE)]
    for i,(n,label,detail,timer,col) in enumerate(phases):
        y=524+i*140;cy=y+58;ink="#FFFFFF" if col==BLUE else "#060909"
        panel(c,72,y,1456,116,col)
        t(c,128,cy,n,22,ink,"JakartaBold","center")
        c.line(184,y+25,184,y+91,ink)
        t(c,224,cy,label,31,ink,"JakartaBold")
        t(c,635,cy,detail,21,ink)
        t(c,1488,cy,timer,60,ink,"Hepta","right")
        for j in range(12):
            x=1090+j*10;c.line(x,y+101,x,y+116-(24 if j%3==0 else 20),ink)
    t(c,72,997,"Simple timers. Custom stacks. Alert sounds.",24,p["ink"])
    c.line(72,1048,1528,1048,p["line"])
    t(c,72,1100,"CREATE YOUR OWN ROUTINE",15,p["muted"],"JakartaBold")
    t(c,1528,1100,"ILLUSTRATIVE TIMINGS · NOT AN APP SCREENSHOT",14,p["muted"],align="right")
    save(c,"Graphics",f"readme-banner-{mode}","Timed workout interval timer for iOS and Android. Standby, work and rest; illustrative durations, not an app screenshot.")


def features(mode):
    p=theme(mode);c=Canvas(1600,720,f"Timed features ({mode})",p["bg"])
    masthead(c,p,"MADE FOR YOUR WORKOUT")
    t(c,72,182,"Your workout. Your structure.",58,p["ink"],"Hepta")
    items=[
        ("01","Simple timers",["Set standby, work and rest.","Choose how many rounds."],GREEN),
        ("02","Advanced stacks",["Build your phase sequence.","Repeat it over multiple cycles."],ORANGE),
        ("03","Yours to change",["Create, edit and delete timers.","Keep the routines you use."],BLUE)]
    for i,(n,head,lines,col) in enumerate(items):
        x=72+i*496;ink="#FFFFFF" if col==BLUE else "#060909"
        panel(c,x,278,464,310,col)
        t(c,x+32,328,n,24,ink,"JakartaBold")
        t(c,x+32,402,head,33,ink,"Hepta")
        for j,line in enumerate(lines):t(c,x+32,481+j*40,line,21,ink)
    t(c,72,658,"User-created timers and sets. No pre-built exercise library.",23,p["muted"])
    save(c,"Graphics",f"features-{mode}","Simple timers, advanced stacks and user-created routines. Create, edit and delete your own timers.")


def workflow(mode):
    p=theme(mode);c=Canvas(1600,740,f"Timed workflow ({mode})",p["bg"])
    masthead(c,p,"FROM AN IDEA TO AN INTERVAL")
    t(c,72,180,"Set it. Stack it. Start.",62,p["ink"],"Hepta")
    for i,(head,detail,col) in enumerate([
        ("Choose your format","Start with a simple or advanced timer.",GREEN),
        ("Build your routine","Set durations, rounds or custom phase cycles.",ORANGE),
        ("Start your session","Follow the countdown and phase-change cues.",BLUE)]):
        y=268+i*128;ink="#FFFFFF" if col==BLUE else "#060909"
        panel(c,72,y,1456,104,col)
        t(c,128,y+52,f"0{i+1}",22,ink,"JakartaBold","center")
        c.line(184,y+24,184,y+80,ink)
        t(c,224,y+52,head,32,ink,"Hepta")
        t(c,880,y+52,detail,23,ink)
    t(c,72,692,"Illustrative workflow. Configure your own timer; no prescribed workout is included.",21,p["muted"])
    save(c,"Graphics",f"workflow-{mode}","Choose simple or advanced, configure durations and repetitions, then run your timer with alert sounds.")


def phases(mode):
    p=theme(mode);c=Canvas(1600,660,f"Timed phases ({mode})",p["bg"])
    masthead(c,p,"THREE PHASES. A RHYTHM YOU CONTROL.")
    t(c,72,180,"Ready. Work. Recover.",62,p["ink"],"Hepta")
    for i,(head,detail,col) in enumerate([
        ("STANDBY","Get ready before the next work phase.",GREEN),
        ("WORK","Follow the duration you choose.",ORANGE),
        ("REST","Make room for recovery.",BLUE)]):
        y=264+i*108;ink="#FFFFFF" if col==BLUE else "#060909"
        panel(c,72,y,1456,84,col)
        t(c,108,y+42,head,30,ink,"JakartaBold")
        t(c,638,y+42,detail,26,ink)
    t(c,72,614,"Phase labels and sounds support the color cues. Never rely on color alone.",21,p["muted"])
    save(c,"Graphics",f"phases-{mode}","Green standby, orange work and blue rest. Each phase is identified by its label as well as its color.")


def timer_types(mode):
    p=theme(mode);c=Canvas(1600,760,f"Timed timer types ({mode})",p["bg"])
    masthead(c,p,"TWO WAYS TO BUILD YOUR ROUTINE")
    t(c,72,182,"Simple rounds. Flexible stacks.",56,p["ink"],"Hepta")
    c.line(800,264,800,650,p["line"])
    for x,n,head in [(72,"01","Simple"),(856,"02","Advanced")]:
        t(c,x,292,n,23,p["muted"],"JakartaBold")
        t(c,x,360,head,44,p["ink"],"Hepta")
    left=["Set standby, work, rest and rounds.",
          "Standby runs once at the beginning.",
          "Work/rest repeats between rounds.",
          "The final round ends after work."]
    right=["Stack your own standby, work and rest phases.",
           "Set a duration for each phase.",
           "Repeat the whole sequence in cycles.",
           "Edit the sequence to fit your workout."]
    for x,lines in [(72,left),(856,right)]:
        for i,line in enumerate(lines):t(c,x,442+i*42,line,23,p["ink"])
    for x in (72,856):
        for i,col in enumerate(COLORS):c.rect(x+i*112,638,96,8,col)
    t(c,72,710,"Diagram summary, not an app screenshot. Your durations and repetitions are configurable.",21,p["muted"])
    save(c,"Graphics",f"timer-types-{mode}","Simple timers use one standby and repeated work/rest rounds, without rest after the last work round. Advanced timers repeat a custom sequence in cycles.")


def social(mode,feature=False):
    p=theme(mode);w,h=(1024,500) if feature else (1200,630)
    c=Canvas(w,h,f"Timed {'Google Play feature graphic' if feature else 'social preview'}",p["bg"])
    t(c,48,42,"INTERVAL TRAINING, ON YOUR TERMS.",15,p["ink"],"JakartaBold")
    t(c,48,142,"Timed",94,p["ink"],"Hepta")
    t(c,48,229,"Make every interval yours.",30,p["ink"],"Hepta")
    mark(c,w-270,78,220)
    for i,(label,timer,col) in enumerate([("STANDBY","00:10",GREEN),("WORK","00:45",ORANGE),("REST","00:15",BLUE)]):
        y=(292 if feature else 330)+i*(48 if feature else 64)
        height=40 if feature else 52;ink="#FFFFFF" if col==BLUE else "#060909"
        panel(c,48,y,w-96,height,col)
        t(c,72,y+height/2,label,18,ink,"JakartaBold")
        t(c,w-72,y+height/2,timer,25,ink,"Hepta","right")
    t(c,48,h-32,"Simple timers. Custom stacks. Alert sounds.",16,p["muted"])
    t(c,w-48,h-32,"iOS / ANDROID",14,p["muted"],"JakartaBold","right")
    folder="Store" if feature else "Graphics"
    name="google-play-feature" if feature else "social-card"
    save(c,folder,f"{name}-{mode}","Timed interval timer. Create your own standby, work and rest routine. Illustrative timing graphic, not a screenshot.")


def brand():
    for mode in ("light","dark"):
        ink=theme(mode)["ink"]
        _,bounds,_=shaped("Timed","Hepta",84,400)
        tw,th=bounds[2]-bounds[0],bounds[3]-bounds[1]
        mw=96/MARK_RATIO
        c=Canvas(round(64+mw+28+tw),160,"Timed horizontal logo")
        mark(c,32,32,mw)
        t(c,32+mw+28,80,"Timed",84,ink,"Hepta")
        save(c,"Brand",f"timed-horizontal-{mode}",f"Transparent Timed horizontal logo for {mode} backgrounds.")
        c=Canvas(round(tw+64),round(th+64),"Timed wordmark")
        t(c,32,0,"Timed",84,ink,"Hepta",top=32)
        save(c,"Brand",f"timed-wordmark-{mode}","Transparent Timed wordmark.")
        c=Canvas(round(tw+64),round(64+96+28+th),"Timed stacked logo")
        mark(c,(c.width-mw)/2,32,mw)
        t(c,c.width/2,0,"Timed",84,ink,"Hepta","center",top=156)
        save(c,"Brand",f"timed-stacked-{mode}","Transparent Timed stacked logo.")
    for variant,col in [("color",None),("black","#000000"),("white","#FFFFFF"),("grayscale","#777777")]:
        c=Canvas(448,418,f"Timed {variant} mark")
        mark(c,32,32,384,col)
        save(c,"Brand",f"timed-mark-{variant}",f"Transparent Timed Interlocking Lanes mark, {variant}.")
    # Tagline is supporting type, never embedded inside the app symbol.
    for mode in ("light","dark"):
        p=theme(mode);c=Canvas(760,240,"Timed logo with optional tagline")
        mark(c,32,32,176/MARK_RATIO)
        t(c,260,90,"Timed",92,p["ink"],"Hepta")
        t(c,260,174,"Make every interval yours.",30,p["ink"],"JakartaBold")
        save(c,"Brand",f"timed-tagline-{mode}",f"Timed Interlocking Lanes logo with a separate tagline for {mode} backgrounds.")


def brand_board(mode):
    p=theme(mode);c=Canvas(1600,920,f"Timed brand overview ({mode})",p["bg"])
    masthead(c,p,"THE TIMED IDENTITY")
    mark(c,72,180,260)
    t(c,388,180+260*MARK_RATIO/2,"Timed",112,p["ink"],"Hepta")
    t(c,72,462,"Hepta Slab",48,p["ink"],"Hepta")
    t(c,72,520,"Display lettering and timer digits",22,p["muted"])
    t(c,72,610,"Plus Jakarta Sans",38,p["ink"])
    t(c,72,668,"Labels, instructions and everyday interface text",22,p["muted"])
    for i,(label,col) in enumerate(zip(("STANDBY","WORK","REST"),COLORS)):
        x=920+i*206
        c.rect(x,180,176,176,col)
        t(c,x,404,label,19,p["ink"],"JakartaBold")
        t(c,x,448,col,20,p["muted"])
    t(c,920,554,"One rhythm. Three phases.",27,p["ink"],"Hepta")
    t(c,920,606,"Linked phases. Clear labels. Open spacing.",21,p["muted"])
    t(c,72,830,"Mobile only: iOS and Android. No desktop or Watch branding.",22,p["muted"])
    save(c,"Previews",f"brand-overview-{mode}","Timed brand: track symbol, Hepta Slab and Plus Jakarta Sans, and green/orange/blue phase colors.")


def contacts(mode):
    p=theme(mode);sheet=Image.new("RGB",(1600,1580),p["bg"])
    d=ImageDraw.Draw(sheet);f=ImageFont.truetype(str(STATIC_FONTS["JakartaBold"]),27)
    d.text((48,24),f"Timed / {mode.title()} graphics",font=f,fill=p["ink"])
    for i,name in enumerate(("readme-banner","features","workflow","phases","timer-types","social-card")):
        x=48+(i%2)*784;y=96+(i//2)*488
        d.text((x,y),name.replace("-"," ").title(),font=f,fill=p["muted"])
        image=Image.open(OUT/"Graphics"/f"{name}-{mode}.png").convert("RGB")
        image.thumbnail((720,425),Image.Resampling.LANCZOS)
        sheet.paste(image,(x,y+44))
    sheet.save(OUT/"Previews"/f"contact-sheet-{mode}.png")
    sheet=Image.new("RGB",(1600,2310),p["bg"])
    d=ImageDraw.Draw(sheet)
    d.text((48,24),f"Timed / Complete README graphics / {mode.title()}",font=f,fill=p["ink"])
    names=("readme-banner","session-overview","features","workflow","timer-types",
           "phases","run-controls","mobile-platforms")
    for i,name in enumerate(names):
        x=48+(i%2)*784;y=96+(i//2)*548
        d.text((x,y),name.replace("-"," ").title(),font=f,fill=p["muted"])
        image=Image.open(OUT/"Graphics"/f"{name}-{mode}.png").convert("RGB")
        image.thumbnail((720,485),Image.Resampling.LANCZOS)
        sheet.paste(image,(x,y+44))
    sheet.save(OUT/"Previews"/f"readme-graphics-{mode}.png")


def main():
    for folder in ("Graphics","Brand","Fonts","Licenses","Instructions","Previews","Store","Web"):
        (OUT/folder).mkdir(parents=True,exist_ok=True)
    source=ROOT/"generated-artifacts/Timed-Standalone-Logo-Options/03-interlocking-lanes"
    if source.exists():
        dest=OUT/"Sources/Symbols";dest.mkdir(parents=True,exist_ok=True)
        for variant in ("color","black","white"):
            node=ET.parse(source/f"symbol-{variant}.svg").getroot()
            # The standalone-symbol export is the canonical approved 180°
            # orientation; copy that source as-is to avoid double rotation.
            node.set("data-brand-orientation","180-clockwise")
            path=dest/f"symbol-{variant}.svg"
            ET.ElementTree(node).write(path,encoding="utf-8",xml_declaration=True)
            subprocess.run(["magick","-background","none",str(path),
                            "-colorspace","sRGB",str(path.with_suffix(".png"))],check=True)
    for mode in ("light","dark"):
        for ext in ("svg","png"):
            (OUT/"Brand"/f"timed-track-lockup-{mode}.{ext}").unlink(missing_ok=True)
    for path in STATIC_FONTS.values():
        pass  # Font is already bundled here.
        f=TTFont(path);f.flavor="woff";f.save(OUT/"Fonts"/path.with_suffix(".woff").name)
    # Licenses are already bundled.
    for mode in ("dark","light"):
        hero(mode);features(mode);workflow(mode);phases(mode);timer_types(mode)
        social(mode);social(mode,True);brand_board(mode)
    brand()
    from timed_readme_graphics import build as build_readme
    build_readme(sys.modules[__name__])
    for mode in ("dark","light"):contacts(mode)
    (OUT/"Graphics"/"text-and-alt-inventory.json").write_text(json.dumps(INVENTORY,indent=2)+"\n")
    print(f"Timed: {len(INVENTORY)} SVG/PNG pairs rendered.",flush=True)


if __name__=="__main__":
    main()
