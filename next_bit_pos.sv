module next_bit_pos(
  input clock,
  input wire [63:0] xb,
  output reg [5:0] y
);

//wire [63:0] xr = x & -x;
//
//function [2:0] ctz8;
//  input [7:0] x;
//begin
//  casez(x)
//    8'b00000000: ctz8 = 3'd0;
//    8'b10000000: ctz8 = 3'd7;
//    8'b?1000000: ctz8 = 3'd6;
//    8'b??100000: ctz8 = 3'd5;
//    8'b???10000: ctz8 = 3'd4;
//    8'b????1000: ctz8 = 3'd3;
//    8'b?????100: ctz8 = 3'd2;
//    8'b??????10: ctz8 = 3'd1;
//    8'b???????1: ctz8 = 3'd0;
//  endcase
//end
//endfunction
//
//wire [7:0] x8 = {
//  |xb[63:56],
//  |xb[55:48],
//  |xb[47:40],
//  |xb[39:32],
//  |xb[31:24],
//  |xb[23:16],
//  |xb[15:8],
//  |xb[7:0]
//};
//
//wire [7:0] x88 = xb[63:56] | xb[55:48] | xb[47:40] | xb[39:32] | xb[31:24] | xb[23:16] | xb[15:8] | xb[7:0];

wire y5 = ~|xb[31:0];
wire [31:0] x5 = xb[63:32] | xb[31:0];

wire y4 = ~|x5[15:0];
wire [15:0] x4 = x5[31:16] | x5[15:0];

wire y3 = ~|x4[7:0];
wire [7:0] x3 = x4[15:8] | x4[7:0];

wire y2 = ~|x3[3:0];
wire [3:0] x2 = x3[7:4] | x3[3:0];

wire y1 = ~|x2[1:0];
wire [1:0] x1 = x2[3:2] | x2[1:0];

wire y0 = ~x1;

always@(posedge clock) begin
  y <= {y5, y4, y3, y2, y1, y0};
end

endmodule