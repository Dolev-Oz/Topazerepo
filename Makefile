TOP = tb
OUT = sim/sim.out

# search for both Verilog and SystemVerilog sources
SRC = $(wildcard rtl/*.v) $(wildcard rtl/*.sv) $(wildcard tb/*.v) $(wildcard tb/*.sv)

# ensure output directory exists
SIMDIR = sim
$(SIMDIR):
	mkdir -p $(SIMDIR)

.PHONY: all compile run wave clean samples.hex

all: run

$(OUT): $(SRC) $(SIMDIR)
	iverilog -g2012 -s $(TOP) -o $(OUT) $(SRC)

run: $(OUT)
	vvp $(OUT)

wave: compile
	vvp $(OUT)
	gtkwave dump.vcd &

# generate a hex sample file from an MP3 (for use by the
# testbench).  Invoke with:
#    make samples.hex MP3=path/to/your.mp3
# The helper script lives in tools/convert_mp3.py and needs pydub/ffmpeg.
samples.hex:
	python3 tools/convert_mp3.py $(MP3) $@

clean:
	rm -f $(OUT) dump.vcd
