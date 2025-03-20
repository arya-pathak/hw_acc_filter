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

integer i, j, k;
reg [7:0] kernel [8:0];
reg [15:0] mult_holder [8:0];
reg [15:0] add_holder;
reg [15:0] add_holder_pipelined;

reg mult_holder_valid;
reg add_holder_valid;

initial begin
    for (i=0; i<9; i=i+1) begin
        kernel[i] = 1;
    end
end

always @(posedge i_clk) begin
    for (j=0; j<9; j=j+1) begin
        mult_holder[j] <= kernel[j] * i_pixel_data[8*j+:8];
    end

    mult_holder_valid <= i_pixel_valid;
end

always @(*) begin
    add_holder = 'd0;

    for (k=0; k<9; k=k+1) begin
        add_holder = add_holder + mult_holder[k];
    end
end

always @(posedge i_clk) begin
    if (mult_holder_valid) begin
        add_holder_pipelined <= add_holder;
    end

    add_holder_valid <= mult_holder_valid;
end

always @(posedge i_clk) begin
    if (add_holder_valid) begin
        o_pixel <= add_holder_pipelined/9;
    end

    o_valid <= add_holder_valid;
end

endmodule

/*
generate
    genvar j;

    for (j=0; j<9; j=j+1) begin
        mult_holder[j] <= kernel[j] * i_pixel_data[8*j+:8];
    end
endgenerate

assign add_holder = mult_holder[0]+mult_holder[1]+mult_holder[2]+mult_holder[3]+mult_holder[4]+mult_holder[5]+mult_holder[6]+mult_holder[7]+mult_holder[8];

assign final = add_holder/9;
*/
