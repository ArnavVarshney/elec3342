// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2023 Advanced Micro Devices, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2023.2 (win64) Build 4029153 Fri Oct 13 20:14:34 MDT 2023
// Date        : Wed Nov 29 11:56:37 2023
// Host        : Arnav-G15 running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub {d:/elec3342/Current -
//               FPGA/elec3342-music-decoder/elec3342-music-decoder.gen/sources_1/ip/clk_wiz_0/clk_wiz_0_stub.v}
// Design      : clk_wiz_0
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7a35tcpg236-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
module clk_wiz_0(clk_12288k, reset, locked, clk_100m)
/* synthesis syn_black_box black_box_pad_pin="reset,locked,clk_100m" */
/* synthesis syn_force_seq_prim="clk_12288k" */;
  output clk_12288k /* synthesis syn_isclock = 1 */;
  input reset;
  output locked;
  input clk_100m;
endmodule
