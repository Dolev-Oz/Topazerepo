import numpy as np
from scipy.io.wavfile import write
import sys

# fs = 16000
fs = 2000
duration = 2     # seconds
f = int(sys.argv[1])          # Hz

# Generate the tone samples
t = np.linspace(0, duration, int(fs*duration), endpoint=False)
y = np.sin(2*np.pi*f*t)

# Convert the sine wave to int16 format (16-bit signed)
y_int16 = np.int16(y * 32767)  # full 16-bit scale

# Save the WAV file
write("tone_70Hz.wav", fs, y_int16)

# Save the hex file for SystemVerilog (use a different variable name to avoid confusion)
with open("audio.hex", "w", newline="\n") as hex_file:
    for s in y_int16:
        # Convert each 16-bit signed integer to bytes (2's complement)
        # 'h' is the format for signed integers, and 2 bytes = 16 bits
        hex_value = int(s).to_bytes(2, byteorder='big', signed=True).hex()
        hex_file.write(f"{hex_value}\n")

print("WAV and hex files generated successfully.")