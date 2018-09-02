all:
	vlib work
	vlog -work work -sv processer_sim.sv
	vlog -work work -sv processer.sv
	vlog -work work -sv score.sv
	vlog -work work -sv popcount.sv
	vlog -work work -sv popcount_8bit.sv
	vlog -work work -sv flip.sv
	vlog -work work -sv flip_impl.sv
	vlog -work work -sv upper_bit.sv
	vsim -L altera_mf_ver -L altera_mf -c -voptargs="+acc" processer_sim -do "radix -hexadecimal; log -r /*; run -all; finish"
