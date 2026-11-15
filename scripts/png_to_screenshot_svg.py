"""Wrap a PNG as the docs/branding screenshot SVG shell (embedded base64)."""
from __future__ import annotations

import argparse
import base64
import struct
from pathlib import Path


def png_size(data: bytes) -> tuple[int, int]:
    if data[:8] != b"\x89PNG\r\n\x1a\n":
        raise ValueError("Not a PNG")
    w, h = struct.unpack(">II", data[16:24])
    return w, h


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("png", type=Path)
    parser.add_argument("svg", type=Path)
    parser.add_argument("--aria-label", default="")
    args = parser.parse_args()

    data = args.png.read_bytes()
    w, h = png_size(data)
    b64 = base64.b64encode(data).decode("ascii")
    label = args.aria_label or args.png.stem
    svg = (
        f'<?xml version="1.0" encoding="UTF-8"?>\n'
        f'<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" '
        f'width="{w}" height="{h}" viewBox="0 0 {w} {h}" role="img" aria-label="{label}">\n'
        f'  <title>{label}</title>\n'
        f'  <image width="{w}" height="{h}" href="data:image/png;base64,{b64}"/>\n'
        f"</svg>\n"
    )
    args.svg.parent.mkdir(parents=True, exist_ok=True)
    args.svg.write_text(svg, encoding="utf-8")
    print(f"Wrote {args.svg} ({w}x{h})")


if __name__ == "__main__":
    main()
