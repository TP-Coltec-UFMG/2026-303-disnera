"""Original, deterministic instrumental loop for Senta e Toca (no samples)."""
import math
import random
import wave
from array import array
from pathlib import Path

RATE = 22050
BEAT = 0.6
LENGTH = 32 * BEAT  # eight 4/4 bars, seamless loop
samples = [0.0] * int(RATE * LENGTH)
rng = random.Random(303)

def note(midi):
    return 440 * 2 ** ((midi - 69) / 12)

def tone(start, duration, midi, gain, kind="guitar"):
    frequency = note(midi)
    count = int(duration * RATE)
    origin = int(start * RATE)
    for i in range(count):
        t = i / RATE
        attack = min(1.0, t / 0.006)
        release = min(1.0, (duration - t) / 0.04)
        phase = 2 * math.pi * frequency * t
        if kind == "guitar":
            env = math.exp(-t * 6) * attack * release
            value = math.sin(phase) + 0.35 * math.sin(2 * phase) + 0.12 * math.sin(3 * phase)
        elif kind == "bass":
            env = math.exp(-t * 3) * attack * release
            value = math.sin(phase) + 0.2 * math.sin(2 * phase)
        else:
            env = attack * release * 0.5
            value = math.sin(phase) + 0.12 * math.sin(2 * phase)
        samples[(origin + i) % len(samples)] += value * env * gain

def drum(start, kind):
    duration = 0.18 if kind != "hat" else 0.055
    origin = int(start * RATE)
    for i in range(int(duration * RATE)):
        t = i / RATE
        noise = rng.uniform(-1, 1)
        if kind == "kick":
            value = math.sin(2 * math.pi * (65 * t + 0.9 * (1 - math.exp(-30 * t)))) * math.exp(-25 * t) * 0.25
        elif kind == "snare":
            value = (noise * 0.7 + math.sin(2 * math.pi * 170 * t) * 0.3) * math.exp(-30 * t) * 0.13
        else:
            value = noise * math.exp(-85 * t) * 0.055
        samples[(origin + i) % len(samples)] += value

chords = [(48, [60, 64, 67, 71]), (45, [60, 64, 67, 69]), (41, [60, 64, 65, 69]), (43, [59, 62, 65, 69])]
melody = [[76, 74, 71, 67], [72, 71, 69, 67], [69, 72, 76, 74], [71, 69, 67, 71]]
for bar in range(8):
    bass, chord = chords[bar % 4]
    start = bar * 4 * BEAT
    for step in range(8):
        drum(start + step * BEAT / 2, "hat")
    for beat in [0, 2]:
        drum(start + beat * BEAT, "kick")
        tone(start + beat * BEAT, 0.48, bass, 0.16, "bass")
    for beat in [1, 3]:
        drum(start + beat * BEAT, "snare")
    for offbeat in [0.5, 1.5, 2.5, 3.5]:
        for voice, pitch in enumerate(chord):
            tone(start + offbeat * BEAT + voice * 0.012, 0.26, pitch, 0.026)
    for pitch in chord:
        tone(start, 2.2, pitch, 0.014, "keys")
    for step, pitch in enumerate(melody[bar % 4]):
        tone(start + step * BEAT + (0.15 if bar % 2 else 0), 0.44, pitch, 0.07)

peak = max(abs(x) for x in samples)
pcm = array("h", (int(x / max(1.0, peak / 0.8) * 32767) for x in samples))
output = Path(__file__).resolve().parents[1] / "Musica/Coltec/senta_e_toca.wav"
with wave.open(str(output), "wb") as track:
    track.setnchannels(1)
    track.setsampwidth(2)
    track.setframerate(RATE)
    track.writeframes(pcm.tobytes())
print(output)
