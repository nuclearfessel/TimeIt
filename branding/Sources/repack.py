import json, hashlib, zipfile
import xml.etree.ElementTree as ET
from pathlib import Path
from PIL import Image, ImageCms
OUT=Path(__file__).resolve().parents[1]

def write(name,text):
    path=OUT/name;path.parent.mkdir(parents=True,exist_ok=True)
    path.write_text(text.strip()+"\n")

def package():
    files=[{"path":p.relative_to(OUT).as_posix(),"bytes":p.stat().st_size,
            "sha256":hashlib.sha256(p.read_bytes()).hexdigest()}
           for p in sorted(OUT.rglob("*")) if p.is_file() and p.name!="asset-manifest.json" and "__pycache__" not in p.parts]
    write("asset-manifest.json",json.dumps({"app":"Timed","files":files},indent=2))
    target=OUT.parent/"timed-complete-brand-pack.zip"
    with zipfile.ZipFile(target,"w",zipfile.ZIP_DEFLATED) as z:
        for item in files:z.write(OUT/item["path"],"Timed/"+item["path"])
        z.write(OUT/"asset-manifest.json","Timed/asset-manifest.json")
    with zipfile.ZipFile(target) as z:
        assert z.testzip() is None
        for item in files:assert hashlib.sha256(z.read("Timed/"+item["path"])).hexdigest()==item["sha256"]
    print(f"Verified {len(files)+1} files; ZIP: {target} ({target.stat().st_size:,} bytes).",flush=True)

if __name__=='__main__':
    package()
