# Simple Verilator flow for the monitor testbench

SIM = verilator
TB  = test/tb_encore_monitor.sv
RTL = rtl/encore_monitor.sv

.PHONY: sim
sim:
	$(SIM) --cc --exe --build -j 4 --top-module tb_encore_monitor \
	  $(TB) $(RTL) \
	  -o Vtb_encore_monitor
	./obj_dir/Vtb_encore_monitor

clean:
	rm -rf obj_dir
