# source comp.tcl


#----

set src_path                "../src"
set bench_path              "../bench"



# IP:
vcom -O0 -93 -work work       $src_path/axi_pwm_generator.vhd

# testbench:
vcom -O0 -93 -work work       $bench_path/axi_pwm_generator_tb.vhd
