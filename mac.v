`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/14/2025 05:30:54 PM
// Design Name: 
// Module Name: mac
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


module mac(
input               i_clk,
input [71:0]        i_pixel_data,
input               i_pixel_valid,
output reg [7:0]    o_pixel,
output reg          o_valid
    );

integer i;
reg [7:0] kernel [8:0];
wire [15:0] mult_holder [8:0];
wire [15:0] add_holder;
wire [8:0] final;

initial begin
    for (i=0; i<9; i=i+1) begin
        kernel[i] = 1;
    end
end

generate
    genvar j;

    for (j=0; j<9; j=j+1) begin
        assign mult_holder[j] = kernel[j] * i_pixel_data[8*j+:8];
    end
endgenerate

assign add_holder = mult_holder[0]+mult_holder[1]+mult_holder[2]+mult_holder[3]+mult_holder[4]+mult_holder[5]+mult_holder[6]+mult_holder[7]+mult_holder[8];

assign final = add_holder/9;

always @(posedge i_clk) begin
    if (i_pixel_valid)
        o_pixel <= final;
end

always @(posedge i_clk) begin
    o_valid <= i_pixel_valid;
end

endmodule
