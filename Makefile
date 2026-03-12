TOP ?= tpz_top_tb
OUT = sim/sim.out

DEBUG ?=
LOG_DEBUG := $(if $(DEBUG),-DLOG_LEVEL=4,)
LOG_LEVEL_OPT := $(if $(LOG_LEVEL),-DLOG_LEVEL=$(LOG_LEVEL),$(LOG_DEBUG))

# Synthesis flags
SYNTHESIS_FLAGS := -g2012
SYNTHESIS_FLAGS += -DSIMULATION
SYNTHESIS_FLAGS += -Iinclude
SYNTHESIS_FLAGS += $(LOG_LEVEL_OPT)

# Parameters (can be overridden from command line)
PARAMS ?= 

# search for both Verilog and SystemVerilog sources
SRC := $(wildcard rtl/*.v rtl/*.sv rtl/*.svh tb/*.v tb/*.sv *.svh)

.PHONY: all
all: $(OUT)

# ensure output directory exists
SIMDIR = sim
$(SIMDIR):
	mkdir -p $(SIMDIR)

$(OUT): $(SRC) $(SIMDIR)
	iverilog $(SYNTHESIS_FLAGS) $(PARAMS) -s $(TOP) -o $(OUT) $(SRC)

.PHONY: run
run: $(OUT)
	vvp $(OUT)

.PHONY: wave
wave: compile
	vvp $(OUT)
	gtkwave dump.vcd &

# generate a hex sample file from an MP3 (for use by the
# testbench).  Invoke with:
#    make samples.hex MP3=path/to/your.mp3
# The helper script lives in tools/convert_mp3.py and needs pydub/ffmpeg.
samples.hex:
	python3 tools/convert_mp3.py $(MP3) $@

.PHONY: clean
clean:
	rm -f $(OUT) dump.vcd
