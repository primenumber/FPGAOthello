`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/05/01 10:46:55
// Design Name: 
// Module Name: feed
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


module feed(
    input clock,
    input reg [17:0] input_data,
    output reg input_full,
    input reg input_enable,
    output reg [23:0] output_data,
    output reg output_empty,
    input reg output_enable
    );

wire empty_fifo;
wire wr_rst_busy_0;
wire rd_rst_busy_0;
wire wr_rst_busy_1;
wire rd_rst_busy_1;
wire solved;

wire [143:0] fifo_out;

fifo_generator_0 input_fifo (
  .clk(clock),                  // input wire clk
  .srst(1'b0),                // input wire srst
  .din(input_data),                  // input wire [17 : 0] din
  .wr_en(input_enable),              // input wire wr_en
  .rd_en(solved),              // input wire rd_en
  .dout(dout),                // output wire [144 : 0] dout
  .full(input_full),                // output wire full
  .empty(empty_fifo),              // output wire empty
  .wr_rst_busy(wr_rst_busy_0),  // output wire wr_rst_busy
  .rd_rst_busy(rd_rst_busy_0)  // output wire rd_rst_busy
);

wire output_full;
wire [63:0] o_result;
wire [63:0] o_player;
wire [7:0] o_opponent;
wire [15:0] o_taskid;
wire [143:0] o_data = {o_result, o_taskid};

fifo_generator_1 output_fifo (
  .clk(clock),                  // input wire clk
  .srst(1'b0),                // input wire srst
  .din(o_data),                  // input wire [143 : 0] din
  .wr_en(solved),              // input wire wr_en
  .rd_en(output_enable),              // input wire rd_en
  .dout(output_data),                // output wire [17 : 0] dout
  .full(output_full),                // output wire full
  .empty(output_empty),              // output wire empty
  .wr_rst_busy(wr_rst_busy_1),  // output wire wr_rst_busy
  .rd_rst_busy(rd_rst_busy_1)  // output wire rd_rst_busy
);

wire valid = !empty_fifo;

pipeline pipeline(
  .iCLOCK(clock),
  .valid(valid),
  .enable(1'b1),
  .iPlayer(fifo_out[63:0]),
  .iOpponent(fifo_out[127:64]),
  .iTaskid(fifo_out[143:128]),
  .solved(solved),
  .oPlayer(o_player),
  .oOpponent(o_opponent),
  .oTaskid(o_taskid),
  .res(o_result),
  .o(o));

endmodule
