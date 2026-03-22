import math

f = 250 # target freq
Fs = 2000 # mic freq

coeff = 2 * math.cos(2*math.pi*f / Fs)

coeff_32 = int(coeff * (2**30))

print(coeff_32)