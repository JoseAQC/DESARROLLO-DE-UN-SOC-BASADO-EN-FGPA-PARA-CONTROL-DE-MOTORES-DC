vlib work
vlib riviera

vlib riviera/xil_defaultlib
vlib riviera/xpm

vmap xil_defaultlib riviera/xil_defaultlib
vmap xpm riviera/xpm

vlog -work xil_defaultlib  -sv2k12 "+incdir+../../../../laboratorio_final.srcs/sources_1/ip/vio_zb/hdl/verilog" "+incdir+../../../../laboratorio_final.srcs/sources_1/ip/vio_zb/hdl" "+incdir+../../../../laboratorio_final.srcs/sources_1/ip/vio_zb/hdl/verilog" "+incdir+../../../../laboratorio_final.srcs/sources_1/ip/vio_zb/hdl" \
"/opt/Xilinx/Vivado/2017.4/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \
"/opt/Xilinx/Vivado/2017.4/data/ip/xpm/xpm_memory/hdl/xpm_memory.sv" \

vcom -work xpm -93 \
"/opt/Xilinx/Vivado/2017.4/data/ip/xpm/xpm_VCOMP.vhd" \

vcom -work xil_defaultlib -93 \
"../../../../laboratorio_final.srcs/sources_1/ip/vio_zb/sim/vio_zb.vhd" \

vlog -work xil_defaultlib \
"glbl.v"

