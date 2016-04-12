`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/03/2016 01:26:16 PM
// Design Name: 
// Module Name: sd_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module sd_tb(

    );
    
    reg clock_rtl;
    reg gpio_io_i;
    wire [1:0] gpio_io_o;
    reg MISO;
    wire MOSI;
    reg reset;
    wire sclk;
    wire chip_sel;
    wire utx;
    reg urx;
    
    initial begin
        clock_rtl <= 1'b0;
        gpio_io_i <= 1'b0;   //chip detection
        MISO <= 1'b1; //no data always
        reset <= 1;
        urx <= 0;
        
        #20 reset <= 0;
    end
    
    always@(clock_rtl) begin
        #10 clock_rtl <= ~clock_rtl;
    end
    
    design_1_wrapper DUT
       (.clock_rtl(clock_rtl),
        .gpio_io_i(gpio_io_i),
        .gpio_io_o(gpio_io_o),
        .io0_o(MOSI),
        .io1_i(MISO),
        .reset_rtl(reset),
        .reset_rtl_0(~reset),
        .sck_o(sclk),
        .ss_o(chip_sel),
        .uart_rtl_rxd(utx),
        .uart_rtl_txd(rtx));
endmodule
