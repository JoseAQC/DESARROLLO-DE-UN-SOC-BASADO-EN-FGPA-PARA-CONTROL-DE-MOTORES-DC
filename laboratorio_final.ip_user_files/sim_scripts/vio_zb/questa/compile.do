vlib questa_lib/work
vlib questa_lib/msim

vlib questa_lib/msim/xil_defaultlib
vlib questa_lib/msim/xpm

vmap xil_defaultlib questa_lib/msim/xil_defaultlib
vmap xpm questa_lib/msim/xpm

vlog -work xil_defaultlib -64 -sv "+incdir+../../../../laboratorio_final.srcs/sources_1/ip/vio_zb/hdl/verilog" "+incdir+../../../../laboratorio_final.srcs/sources_1/ip/vio_zb/hdl" "+incdir+../../../../laboratorio_final.srcs/sources_1/ip/vio_zb/hdl/verilog" "+incdir+../../../../laboratorio_final.srcs/sources_1/ip/vio_zb/hdl" \
"/opt/Xilinx/Vivado/2017.4/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \
"/opt/Xilinx/Vivado/2017.4/data/ip/xpm/xpm_memory/hdl/xpm_memory.sv" \

vcom -work xpm -64 -93 \
"/opt/Xilinx/Vivado/2017.4/data/ip/xpm/xpm_VCOMP.vhd" \

vcom -work xil_defaultlib -64 -93 \
"../../../../laboratorio_final.srcs/sources_1/ip/vio_zb/sim/vio_zb.vhd" \

vlog -work xil_defaultlib \
"glbl.v"

