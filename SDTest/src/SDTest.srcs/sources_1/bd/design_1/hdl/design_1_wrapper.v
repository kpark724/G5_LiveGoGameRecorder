//Copyright 1986-2015 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2015.4 (win64) Build 1412921 Wed Nov 18 09:43:45 MST 2015
//Date        : Tue Mar 29 14:33:54 2016
//Host        : jesse-lap running 64-bit major release  (build 9200)
//Command     : generate_target design_1_wrapper.bd
//Design      : design_1_wrapper
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module design_1_wrapper
   (clock_rtl,
    gpio_io_i,
    gpio_io_o,
    io0_o,
    io1_i,
    reset_rtl,
    reset_rtl_0,
    sck_o,
    ss_o,
    uart_rtl_rxd,
    uart_rtl_txd);
  input clock_rtl;
  input [0:0]gpio_io_i;
  output [1:0]gpio_io_o;
  output io0_o;
  input io1_i;
  input reset_rtl;
  input reset_rtl_0;
  output sck_o;
  output [0:0]ss_o;
  input uart_rtl_rxd;
  output uart_rtl_txd;

  wire clock_rtl;
  wire [0:0]gpio_io_i;
  wire [1:0]gpio_io_o;
  wire io0_o;
  wire io1_i;
  wire reset_rtl;
  wire reset_rtl_0;
  wire sck_o;
  wire [0:0]ss_o;
  wire uart_rtl_rxd;
  wire uart_rtl_txd;

  design_1 design_1_i
       (.clock_rtl(clock_rtl),
        .gpio_io_i(gpio_io_i),
        .gpio_io_o(gpio_io_o),
        .io0_o(io0_o),
        .io1_i(io1_i),
        .reset_rtl(reset_rtl),
        .reset_rtl_0(reset_rtl_0),
        .sck_o(sck_o),
        .ss_o(ss_o),
        .uart_rtl_rxd(uart_rtl_rxd),
        .uart_rtl_txd(uart_rtl_txd));
endmodule
