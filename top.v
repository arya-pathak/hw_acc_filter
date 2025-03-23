`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/14/2025 08:19:04 PM
// Design Name: 
// Module Name: control
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

module top(
input   axi_clk,
input   axi_reset_n,
//slave interface
input   i_data_valid,
input [7:0] i_data,
output  o_data_ready,
//master interface
output  o_data_valid,
output [7:0] o_data,
input   i_data_ready,
//interrupt
output  o_intr
    );

wire [71:0] unconvulved;
wire unconvulved_valid;

wire [7:0] convulved;
wire convulved_valid;

wire axis_prog_full;

assign o_data_ready = !axis_prog_full;

control cont(
    .i_clk(axi_clk),
    .i_rst(!axi_reset_n),
    .i_pixel_data(i_data),
    .i_valid(i_data_valid),
    .o_pixel_data(unconvulved),
    .o_valid(unconvulved_valid),
    .o_intr(o_intr)
    );

mac mult_acc(
    .i_clk(axi_clk),
    .i_pixel_data(unconvulved),
    .i_pixel_valid(unconvulved_valid),
    .o_pixel(convulved),
    .o_valid(convulved_valid)
    );

out_buf fifo (
  .wr_rst_busy(),        // output wire wr_rst_busy
  .rd_rst_busy(),        // output wire rd_rst_busy
  .s_aclk(axi_clk),                  // input wire s_aclk
  .s_aresetn(axi_reset_n),            // input wire s_aresetn
  .s_axis_tvalid(convulved_valid),    // input wire s_axis_tvalid
  .s_axis_tready(),    // output wire s_axis_tready
  .s_axis_tdata(convulved),      // input wire [7 : 0] s_axis_tdata
  .m_axis_tvalid(o_data_valid),    // output wire m_axis_tvalid
  .m_axis_tready(i_data_ready),    // input wire m_axis_tready
  .m_axis_tdata(o_data),      // output wire [7 : 0] m_axis_tdata
  .axis_prog_full(axis_prog_full)  // output wire axis_prog_full
);

endmodule
