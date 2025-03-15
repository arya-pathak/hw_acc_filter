`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/14/2025 02:35:44 PM
// Design Name: 
// Module Name: line_buffer
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


module line_buffer(
input           i_clk,
input           i_rst,
input [7:0]     i_pixel,
input           i_pixel_valid,
output [23:0]   o_data,
input           i_read_data
    );

reg [7:0] line_buffer [511:0];
reg [8:0] write_pos;
reg [8:0] read_pos;

always @(posedge i_clk) begin
    if (i_rst) begin
        write_pos <= 'd0;
    end else if (i_pixel_valid) begin
        write_pos <= write_pos + 'd1;
    end
end

always @(posedge i_clk) begin
    if (i_rst) begin
        read_pos <= 'd0;
    end else if (i_read_data) begin
        read_pos <= read_pos + 'd1;
    end
end

always @(posedge i_clk) begin
    if (i_pixel_valid) begin
        line_buffer[write_pos] <= i_pixel;
    end
end

assign o_data = {line_buffer[read_pos], line_buffer[read_pos+'d1], line_buffer[read_pos+'d2]};

endmodule
