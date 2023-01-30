vlib modelsim_lib/work
vlib modelsim_lib/msim

vlib modelsim_lib/msim/xil_defaultlib
vlib modelsim_lib/msim/xpm

vmap xil_defaultlib modelsim_lib/msim/xil_defaultlib
vmap xpm modelsim_lib/msim/xpm

vlog -work xil_defaultlib -64 -incr -sv "+incdir+../../../../laboratorio_final.srcs/sources_1/ip/vio_zb/hdl/verilog" "+incdir+../../../../laboratorio_final.srcs/sources_1/ip/vio_zb/hdl" "+incdir+../../../../laboratorio_final.srcs/sources_1/ip/vio_zb/hdl/verilog" "+incdir+../../../../laboratorio_final.srcs/sources_1/ip/vio_zb/hdl" \
"/opt/Xilinx/Vivado/2017.4/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \
"/opt/Xilinx/Vivado/2017.4/data/ip/xpm/xpm_memory/hdl/xpm_memory.sv" \

vcom -work xpm -64 -93 \
"/opt/Xilinx/Vivado/2017.4/data/ip/xpm/xpm_VCOMP.vhd" \

vcom -work xil_defaultlib -64 -93 \
"../../../../laboratorio_final.srcs/sources_1/ip/vio_zb/sim/vio_zb.vhd" \

vlog -work xil_defaultlib \
"glbl.v"

