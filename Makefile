FLIP8_SRCS:=flip_8bit.sv flip_8bit_half.sv
TEST_FLIP8_SRCS:=test_flip8.sv $(FLIP8_SRCS)
FLIP_SRCS:=flip_v2.sv extract_v.sv extract_a1h8.sv extract_a8h1.sv shift64.sv $(FLIP8_SRCS)
TEST_FLIP_SRCS:=test_flip_v2.sv flip.sv flip_impl.sv upper_bit.sv $(FLIP_SRCS)
SRCS:=iv_sim.sv pipeline.sv bram.sv flip.sv flip_impl.sv popcount.sv popcount_8bit.sv upper_bit.sv next_bit_pos.sv $(FLIP_SRCS)
IVFLAGS:=-g2012
CXXFLAGS:=-std=c++17 -O2 -Wall -Wextra
TARGETS:=reference-flip8.txt reference-flip.txt reference-pipeline.txt test-flip8 test-flip test-pipeline

all: $(TARGETS)

test-flip8: $(TEST_FLIP8_SRCS)
	iverilog -o $@ $(IVFLAGS) $^

test-flip: $(TEST_FLIP_SRCS)
	iverilog -o $@ $(IVFLAGS) $^

reference-flip8.txt: gen-test-flip8
	./$^ > $@

gen-test-flip8: gen_test_flip8.o reversi.o
	$(CXX) -o $@ $(CXXFLAGS) $^

reference-flip.txt: gen-test-flip
	./$^ > $@

gen-test-flip: gen_test_flip_v2.o reversi.o
	$(CXX) -o $@ $(CXXFLAGS) $^

reference-pipeline.txt: gen-test-pipeline
	./$^ > $@

gen-test-pipeline: gen_test_pipeline.o reversi.o
	$(CXX) -o $@ $(CXXFLAGS) $^

test-pipeline: $(SRCS)
	iverilog -o $@ -g2012 $(SRCS)

%.o: %.cpp
	$(CXX) -c -o $@ $(CXXFLAGS) $<

.PHONY: old-test
old-test:
	vlib work
	vlog -work work -sv processer_sim.sv
	vlog -work work -sv pipeline.sv
	vlog -work work -sv score.sv
	vlog -work work -sv popcount.sv
	vlog -work work -sv popcount_8bit.sv
	vlog -work work -sv flip.sv
	vlog -work work -sv flip_impl.sv
	vlog -work work -sv upper_bit.sv
	vsim -L altera_mf_ver -L altera_mf -c -voptargs="+acc" processer_sim -do "radix -hexadecimal; log -r /*; run -all; finish"
