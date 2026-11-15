"""Synthesize six short mono 44.1 kHz WAV alert tones for TimeIt."""
from __future__ import annotations

import math
import struct
import wave
from pathlib import Path

RATE = 44100
OUT = Path(__file__).resolve().parents[1] / "app" / "assets" / "sounds"


def write_wav(path: Path, samples: list[float]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with wave.open(str(path), "w") as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(RATE)
        frames = bytearray()
        for s in samples:
            v = max(-1.0, min(1.0, s))
            frames += struct.pack("<h", int(v * 32767))
        w.writeframes(frames)
    print(f"Wrote {path.name} ({len(samples) / RATE:.3f}s)")


def envelope(i: int, n: int, attack: float = 0.008, release: float = 0.04) -> float:
    t = i / RATE
    dur = n / RATE
    a = min(1.0, t / attack) if attack > 0 else 1.0
    r = 1.0
    if release > 0 and t > dur - release:
        r = max(0.0, (dur - t) / release)
    return a * r


def sine(freq: float, dur: float, amp: float = 0.55) -> list[float]:
    n = int(RATE * dur)
    return [
        amp * math.sin(2 * math.pi * freq * i / RATE) * envelope(i, n)
        for i in range(n)
    ]


def squareish(freq: float, dur: float, amp: float = 0.28) -> list[float]:
    n = int(RATE * dur)
    out = []
    for i in range(n):
        phase = (i * freq / RATE) % 1.0
        raw = 1.0 if phase < 0.5 else -1.0
        # Soften edges with a little sine mix
        s = 0.7 * raw + 0.3 * math.sin(2 * math.pi * freq * i / RATE)
        out.append(amp * s * envelope(i, n, attack=0.004, release=0.03))
    return out


def chirp(f0: float, f1: float, dur: float, amp: float = 0.5) -> list[float]:
    n = int(RATE * dur)
    out = []
    for i in range(n):
        t = i / RATE
        # Linear sweep
        f = f0 + (f1 - f0) * (t / dur)
        out.append(amp * math.sin(2 * math.pi * f * t) * envelope(i, n, 0.005, 0.05))
    return out


def two_tone(f1: float, f2: float, each: float = 0.16, amp: float = 0.5) -> list[float]:
    a = sine(f1, each, amp)
    b = sine(f2, each, amp)
    gap = [0.0] * int(RATE * 0.03)
    return a + gap + b


def main() -> None:
    tones = {
        # Defaults aligned with previous role feel
        "tone_blip.wav": sine(1760, 0.08, 0.5),  # short high — good end beep
        "tone_pip.wav": sine(880, 0.16, 0.55),  # mid — good start beep
        "tone_chime.wav": two_tone(660, 990, 0.18, 0.5),  # finish
        "tone_buzz.wav": squareish(220, 0.14, 0.32),
        "tone_chirp.wav": chirp(600, 1400, 0.18, 0.48),
        "tone_pulse.wav": sine(523.25, 0.12, 0.52),  # C5
    }
    for name, samples in tones.items():
        write_wav(OUT / name, samples)


if __name__ == "__main__":
    main()
