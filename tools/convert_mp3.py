#!/usr/bin/env python3
"""Convert an MP3 file to a hex sample list suitable for SystemVerilog
`$fscanf` or `$readmemh`.

Dependencies:
    pip install pydub
    and have ffmpeg/avlib installed on the system.

Usage:
    python tools/convert_mp3.py in.mp3 out.hex

The output file contains one 16‑bit signed sample per line in hex
(lowercase), e.g. `ff81` for -127.  You can then point your testbench at
this file and the bench will stream the samples as if they were coming from
a microphone ADC.
"""
import sys

try:
    from pydub import AudioSegment
except ImportError:
    sys.exit("pydub is required; install with `pip install pydub`.")

if len(sys.argv) != 3:
    print(__doc__)
    sys.exit(1)

infile = sys.argv[1]
outfile = sys.argv[2]

# decode audio
audio = AudioSegment.from_file(infile, format="mp3")
# convert to 16‑bit mono PCM; you can adjust frame_rate if you need a
# particular sample rate (e.g. 48000 or 44100 Hz).
audio = audio.set_channels(1).set_sample_width(2)

samples = audio.get_array_of_samples()

with open(outfile, "wb") as f:
    for s in samples:
        # mask to 16 bits just in case
        # f.write(f"{(s & 0xffff):04x}\n")
        f.write((s & 0xffff).to_bytes(2, byteorder="little", signed=False))

print(f"wrote {len(samples)} samples to {outfile}")
