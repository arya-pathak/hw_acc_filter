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

// `define blur;

module mac(
input               i_clk,
input [71:0]        i_pixel_data,
input               i_pixel_valid,
output reg [7:0]    o_pixel,
output reg          o_valid
    );

integer i, j, k;

`ifdef blur
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

`else
reg [7:0] kernel1 [8:0];
reg [7:0] kernel2 [8:0];
reg [15:0] mult_holder1 [8:0];
reg [15:0] mult_holder2 [8:0];
reg [15:0] add_holder1;
reg [15:0] add_holder_pipelined1;
reg [15:0] add_holder2;
reg [15:0] add_holder_pipelined2;
reg mult_holder_valid1;
reg add_holder_valid1;
reg mult_holder_valid2;
reg add_holder_valid2;
reg [31:0] g1;
reg [31:0] g2;
reg [32:0] threshold;
reg square_holder_valid1;
reg square_holder_valid2;
reg threshold_valid;

initial begin
    kernel1[0] =  1;
    kernel1[1] =  0;
    kernel1[2] = -1;
    kernel1[3] =  2;
    kernel1[4] =  0;
    kernel1[5] = -2;
    kernel1[6] =  1;
    kernel1[7] =  0;
    kernel1[8] = -1;

    kernel2[0] =  1;
    kernel2[1] =  2;
    kernel2[2] =  1;
    kernel2[3] =  0;
    kernel2[4] =  0;
    kernel2[5] =  0;
    kernel2[6] = -1;
    kernel2[7] = -2;
    kernel2[8] = -1;
end    

always @(posedge i_clk) begin
    for (j=0; j<9; j=j+1) begin
        mult_holder1[j] <= $signed(kernel1[j]) * $signed(i_pixel_data[8*j+:8]);
        mult_holder2[j] <= $signed(kernel2[j]) * $signed(i_pixel_data[8*j+:8]);
    end

    mult_holder_valid1 <= i_pixel_valid;
    mult_holder_valid2 <= i_pixel_valid;
end

always @(*) begin
    add_holder1 = 'd0;

    for (k=0; k<9; k=k+1) begin
        add_holder1 = $signed(add_holder1) + $signed(mult_holder1[k]);
    end
end

always @(*) begin
    add_holder2 = 'd0;

    for (k=0; k<9; k=k+1) begin
        add_holder2 = $signed(add_holder2) + $signed(mult_holder2[k]);
    end
end

always @(posedge i_clk) begin
    add_holder_pipelined1 <= add_holder1;
    add_holder_pipelined2 <= add_holder2;

    add_holder_valid1 <= mult_holder_valid1;
    add_holder_valid2 <= mult_holder_valid2;
end

always @(posedge i_clk) begin
    g1 <= $signed(add_holder_pipelined1)*$signed(add_holder_pipelined1);
    g2 <= $signed(add_holder_pipelined2)*$signed(add_holder_pipelined2);

    square_holder_valid1 <= add_holder_valid1;
    square_holder_valid2 <= add_holder_valid2;
end

always @(posedge i_clk) begin
    threshold <= g1+g2;
    threshold_valid <= (square_holder_valid1 && square_holder_valid2);
end

always @(posedge i_clk) begin
    if (threshold > 8000)
        o_pixel <= 8'hff;
    else
        o_pixel <= 8'h0;

    o_valid <= threshold_valid;
end
`endif

endmodule

/*

COMPLETELY COMBINATIONAL IMPLEMENTATION: DOES NOT SATISFY TIMING CONSTRAINTS

generate
    genvar j;

    for (j=0; j<9; j=j+1) begin
        mult_holder[j] <= kernel[j] * i_pixel_data[8*j+:8];
    end
endgenerate

assign add_holder = mult_holder[0]+mult_holder[1]+mult_holder[2]+mult_holder[3]+mult_holder[4]+mult_holder[5]+mult_holder[6]+mult_holder[7]+mult_holder[8];

assign final = add_holder/9;
*/
