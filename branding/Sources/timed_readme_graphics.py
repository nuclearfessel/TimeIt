"""Illustrated README panels; explicitly not screenshots of the app."""


def phone(g,c,x,y,w,h,p,phase,label,time):
    c.rect(x,y,w,h,p["ink"],radius=42)
    c.rect(x+9,y+9,w-18,h-18,p["surface"],radius=34)
    c.rect(x+w/2-35,y+18,70,7,p["ink"],radius=4)
    g.mark(c,x+24,y+48,30)
    g.t(c,x+68,y+63,"Timed",25,p["ink"],"Hepta")
    c.rect(x+20,y+114,w-40,h-242,phase,radius=16)
    ink="#FFFFFF" if phase==g.BLUE else "#060909"
    g.t(c,x+w/2,y+160,label,22,ink,"JakartaBold","center")
    g.t(c,x+w/2,y+235,time,64,ink,"Hepta","center")
    next_phase="REST" if label=="WORK" else "WORK"
    g.t(c,x+w/2,y+h-168,f"UP NEXT / {next_phase}",15,ink,"JakartaBold","center")
    c.rect(x+24,y+h-104,w-48,52,p["ink"],radius=26)
    g.t(c,x+w/2,y+h-78,"Pause",20,p["bg"],"JakartaBold","center")
    c.rect(x+w/2-40,y+h-24,80,4,p["ink"],radius=2)


def session(g,mode):
    p=g.theme(mode);c=g.Canvas(1600,1000,"Timed / session overview",p["bg"])
    g.masthead(c,p,"YOUR SESSION, AT A GLANCE")
    g.t(c,72,184,"Your next interval, in focus.",58,p["ink"],"Hepta")
    phone(g,c,1144,274,324,596,p,g.ORANGE,"WORK","00:45")
    rows=[
        ("STANDBY","A moment to get ready.","00:10",g.GREEN),
        ("WORK","The interval you chose.","00:45",g.ORANGE),
        ("REST","Space to recover.","00:15",g.BLUE),
    ]
    for i,(label,copy,digits,col) in enumerate(rows):
        y=292+i*176;ink="#FFFFFF" if col==g.BLUE else "#060909"
        g.panel(c,72,y,944,142,col)
        g.t(c,108,y+44,label,24,ink,"JakartaBold")
        g.t(c,108,y+98,copy,25,ink)
        g.t(c,972,y+71,digits,52,ink,"Hepta","right")
    g.t(c,72,900,"Phase labels. Countdown digits. A clear next step.",28,p["ink"],"Hepta")
    c.line(72,936,1528,936,p["line"])
    g.t(c,72,970,"CONCEPT ILLUSTRATION · NOT AN APP SCREENSHOT · SAMPLE DURATIONS",14,p["muted"],"JakartaBold")
    g.save(c,"Graphics",f"session-overview-{mode}",
           "Illustrated standby, work and rest phases alongside a conceptual phone timer, not an app screenshot. Durations are examples.")


def controls(g,mode):
    p=g.theme(mode);c=g.Canvas(1600,900,"Timed / run controls",p["bg"])
    g.masthead(c,p,"YOU CONTROL THE SESSION")
    g.t(c,72,184,"Keep your own pace.",62,p["ink"],"Hepta")
    items=[
        ("Start","Begin the timer.",g.GREEN,"play"),
        ("Pause / Resume","Stop, then continue.",g.ORANGE,"pause"),
        ("Skip","Go to the next phase.",g.BLUE,"skip"),
        ("Reset","Return to the first phase.",p["ink"],"reset"),
    ]
    for i,(name,detail,col,kind) in enumerate(items):
        x=72+i*372
        c.rect(x,300,340,350,p["surface"],stroke=p["line"],radius=16)
        c.rect(x+28,328,96,96,col,radius=24)
        ink="#FFFFFF" if col in (g.BLUE,p["ink"]) else "#060909"
        if col==p["ink"]:ink=p["bg"]
        if kind=="play":
            c.element("path",{"d":f"M{x+62} 350L{x+96} 376L{x+62} 402Z","fill":ink})
        elif kind=="pause":
            for dx in (57,83):c.rect(x+dx,352,12,48,ink)
        elif kind=="skip":
            c.element("path",{"d":f"M{x+54} 352L{x+86} 376L{x+54} 400Z","fill":ink})
            c.rect(x+92,352,8,48,ink)
        else:
            c.element("path",{"d":f"M{x+100} 384A27 27 0 1 1 {x+75} 349",
                "fill":"none","stroke":ink,"stroke-width":6,"stroke-linecap":"round"})
            c.element("path",{"d":f"M{x+73} 338L{x+89} 350L{x+73} 362Z","fill":ink})
        g.t(c,x+28,480,name,29,p["ink"],"Hepta")
        g.t(c,x+28,548,detail,21,p["ink"])
    g.t(c,72,730,"Simple or advanced: the same essential run controls.",29,p["ink"],"Hepta")
    c.line(72,802,1528,802,p["line"])
    g.t(c,72,850,"CONTROL DIAGRAM · NOT INTERACTIVE BUTTONS OR AN APP SCREENSHOT",15,p["muted"],"JakartaBold")
    g.save(c,"Graphics",f"run-controls-{mode}",
           "Start begins the timer; Pause and Resume stop and continue; Skip advances a phase; Reset returns to the first phase. Illustrated controls, not a screenshot.")


def platforms(g,mode):
    p=g.theme(mode);c=g.Canvas(1600,960,"Timed / mobile platforms",p["bg"])
    g.masthead(c,p,"BUILT FOR YOUR PHONE")
    g.t(c,72,184,"One timer. Two platforms.",60,p["ink"],"Hepta")
    phone(g,c,152,286,280,540,p,g.GREEN,"STANDBY","00:10")
    phone(g,c,508,286,280,540,p,g.BLUE,"REST","00:15")
    g.t(c,292,866,"iOS",26,p["ink"],"JakartaBold","center")
    g.t(c,648,866,"Android",26,p["ink"],"JakartaBold","center")
    g.mark(c,946,296,116)
    g.t(c,1092,350,"Timed",70,p["ink"],"Hepta")
    for i,line in enumerate(["Your own timers.","Simple rounds or custom stacks.","Standby, work and rest."]):
        g.t(c,944,484+i*57,line,27,p["ink"])
    g.t(c,944,720,"Downloads and install instructions:",20,p["muted"])
    g.t(c,944,762,"See GitHub Releases and the guide.",22,p["ink"],"JakartaBold")
    c.line(72,902,1528,902,p["line"])
    g.t(c,72,936,"CONCEPT DEVICES · NOT SCREENSHOTS · RELEASE AVAILABILITY VARIES BY PLATFORM",14,p["muted"],"JakartaBold")
    g.save(c,"Graphics",f"mobile-platforms-{mode}",
           "Timed for iOS and Android, with conceptual phone illustrations, not screenshots. Check GitHub Releases and the guide for current packages and signing requirements.")


def build(g):
    for mode in ("light","dark"):
        session(g,mode);controls(g,mode);platforms(g,mode)
