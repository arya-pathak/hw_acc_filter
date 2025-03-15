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

module control(
input           i_clk,
input           i_rst,
input [7:0]     i_pixel_data,
input           i_valid,
output [71:0]   o_pixel_data,
output          o_valid
    );

reg [8:0] wr_pixel_pos;
reg [1:0] wr_lb;

reg [8:0] rd_pixel_pos;
reg rd_lb;
reg [3:0] rd_data;

reg [10:0] total_pixel_count;

reg [3:0] lb_i_valid;
reg [23:0] lb_i_data [3:0];

wire [23:0] lb0_data;
wire [23:0] lb1_data;
wire [23:0] lb2_data;
wire [23:0] lb3_data;

reg [71:0] o_data_reg;

integer i, j;

assign o_valid = rd_lb;
assign o_pixel_data = o_data_reg;

always @(*) begin
    for (i=0; i<4; i=i+1) begin
        if (wr_lb == i) begin
            lb_i_valid[i] = i_valid;
        end else begin
            lb_i_valid[i] = 'd0;
        end
    end
end

always @(*) begin
    for (i=0; i<4; i=i+1) begin
        if (wr_lb == i) begin
            rd_data[i] = 'd0;
        end else begin
            rd_data[i] = rd_lb;
        end
    end
end

always @(posedge i_clk) begin
    if (i_rst) begin
        wr_pixel_pos <= 0;
    end else if (i_pixel_data) begin
        wr_pixel_pos <= wr_pixel_pos + 'd1;
    end
end

always @(posedge i_clk) begin

    if (i_rst) begin
        total_pixel_count <= 'd0;
    end else if (i_valid && (!rd_lb)) begin
        total_pixel_count <= total_pixel_count + 'd1;
    end else if (!i_valid && rd_lb) begin
        total_pixel_count <= total_pixel_count - 'd1;
    end
end

always @(posedge i_clk) begin

end

parameter WAIT=0, READ=1;
reg state, next_state;
reg out_state;

always @(*) begin
    case (state)
        WAIT: begin
            if (total_pixel_count == 1536) begin
                next_state = READ;
            end
        end

        READ: begin
            if (rd_pixel_pos == 511) begin
                next_state = WAIT;
            end
        end
    endcase

    rd_lb = out_state;
end

always @(posedge i_clk) begin
    if (i_rst) begin
        state <= WAIT;
        out_state = 'd0;
    end else begin
        state <= next_state;
        out_state <= next_state;
    end
end

always @(posedge i_clk) begin
    if (i_rst) begin
        rd_pixel_pos <= 0;
    end else if (rd_lb) begin
        rd_pixel_pos <= rd_pixel_pos + 'd1;
    end   
end

always @(posedge i_clk) begin
    if (i_rst) begin
        wr_lb <= 0;
    end else if (wr_pixel_pos == 511 && i_valid) begin
        wr_lb <= wr_lb + 'd1;
    end
end

always @(*)
begin
    case(wr_lb)
        0:begin
            o_data_reg = {lb1_data, lb2_data, lb3_data};
        end
        1:begin
            o_data_reg = {lb2_data, lb3_data, lb0_data};
        end
        2:begin
            o_data_reg = {lb3_data, lb0_data, lb0_data};
        end
        3:begin
            o_data_reg = {lb0_data, lb1_data, lb2_data};
        end
    endcase
end

line_buffer lb0(
    .i_clk(i_clk),
    .i_rst(i_rst),
    .i_pixel(i_pixel_data),
    .i_pixel_valid(lb_i_valid[0]),
    .o_data(lb0_data),
    .i_read_data(rd_data[0])
 ); 

line_buffer lb1(
    .i_clk(i_clk),
    .i_rst(i_rst),
    .i_pixel(i_pixel_data),
    .i_pixel_valid(lb_i_valid[1]),
    .o_data(lb1_data),
    .i_read_data(rd_data[1])
 ); 

line_buffer lb2(
    .i_clk(i_clk),
    .i_rst(i_rst),
    .i_pixel(i_pixel_data),
    .i_pixel_valid(lb_i_valid[2]),
    .o_data(lb2_data),
    .i_read_data(rd_data[2])
 );

line_buffer lb3(
    .i_clk(i_clk),
    .i_rst(i_rst),
    .i_pixel(i_pixel_data),
    .i_pixel_valid(lb_i_valid[3]),
    .o_data(lb3_data),
    .i_read_data(rd_data[3])
 ); 

endmodule
