-- Copyright 1986-2017 Xilinx, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2017.4 (lin64) Build 2086221 Fri Dec 15 20:54:30 MST 2017
-- Date        : Wed Jun  1 19:12:56 2022
-- Host        : PC12-L6 running 64-bit unknown
-- Command     : write_vhdl -force -mode synth_stub
--               /home/alberto.miguel/seda_labs/LABORATORIO_FINAL/laboratorio_final/laboratorio_final.srcs/sources_1/ip/vio_zb/vio_zb_stub.vhdl
-- Design      : vio_zb
-- Purpose     : Stub declaration of top-level module interface
-- Device      : xc7z020clg484-1
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity vio_zb is
  Port ( 
    clk : in STD_LOGIC;
    probe_out0 : out STD_LOGIC_VECTOR ( 7 downto 0 )
  );

end vio_zb;

architecture stub of vio_zb is
attribute syn_black_box : boolean;
attribute black_box_pad_pin : string;
attribute syn_black_box of stub : architecture is true;
attribute black_box_pad_pin of stub : architecture is "clk,probe_out0[7:0]";
attribute X_CORE_INFO : string;
attribute X_CORE_INFO of stub : architecture is "vio,Vivado 2017.4";
begin
end;
