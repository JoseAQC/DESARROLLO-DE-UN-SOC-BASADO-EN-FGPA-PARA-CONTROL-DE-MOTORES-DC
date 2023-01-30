// Copyright 1986-2017 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2017.4 (lin64) Build 2086221 Fri Dec 15 20:54:30 MST 2017
// Date        : Wed Jun  1 19:12:56 2022
// Host        : PC12-L6 running 64-bit unknown
// Command     : write_verilog -force -mode synth_stub
//               /home/alberto.miguel/seda_labs/LABORATORIO_FINAL/laboratorio_final/laboratorio_final.srcs/sources_1/ip/vio_zb/vio_zb_stub.v
// Design      : vio_zb
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7z020clg484-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* X_CORE_INFO = "vio,Vivado 2017.4" *)
module vio_zb(clk, probe_out0)
/* synthesis syn_black_box black_box_pad_pin="clk,probe_out0[7:0]" */;
  input clk;
  output [7:0]probe_out0;
endmodule
