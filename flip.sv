module flip(
  input wire iCLOCK,
  input wire [63:0] iPlayer,
  input wire [63:0] iOpponent,
  input wire [5:0] iPos,
  output reg [63:0] oFlip
);

localparam O_MASK = 64'h7e7e7e7e7e7e7e7e;

wire [63:0] OM;

assign OM = iOpponent & O_MASK;

wire [63:0] flipA;
wire [63:0] flipB;
wire [63:0] flipC;
wire [63:0] flipD;

flip_impl FLIP_A(
  .*,
  .iMaskA(64'h0080808080808080),
  .iMaskB(64'h0101010101010100),
  .oFlip(flipA)
);
  
flip_impl FLIP_B(
  .*,
  .iOpponent(OM),
  .iMaskA(64'h7f00000000000000),
  .iMaskB(64'h00000000000000fe),
  .oFlip(flipB)
);
  
flip_impl FLIP_C(
  .*,
  .iOpponent(OM),
  .iMaskA(64'h0102040810204000),
  .iMaskB(64'h0002040810204080),
  .oFlip(flipC)
);
  
flip_impl FLIP_D(
  .*,
  .iOpponent(OM),
  .iMaskA(64'h0040201008040201),
  .iMaskB(64'h8040201008040200),
  .oFlip(flipD)
);

always@(posedge iCLOCK)begin
  oFlip <= flipA | flipB | flipC | flipD;
end

endmodule
