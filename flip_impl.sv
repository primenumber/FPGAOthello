module flip_impl(
  input wire iCLOCK,
  input wire [63:0] iPlayer,
  input wire [63:0] iOpponent,
  input wire [5:0] iPos,
  input wire [63:0] iMaskA,
  input wire [63:0] iMaskB,
  output wire [63:0] oFlip
);

wire [5:0] negpos;

assign negpos = ~iPos;

wire [63:0] maskA;

assign maskA = iMaskA >> negpos;

reg [63:0] iUB;
wire [63:0] oUB;

reg [63:0] player2;
reg [63:0] maskA2;

always@(posedge iCLOCK) begin
  iUB <= ~iOpponent & maskA;
  player2 <= iPlayer;
  maskA2 <= maskA;
end

upper_bit UPPER_BIT(
  .*,
  .i(iUB),
  .o(oUB)
);

reg [63:0] player3;
reg [63:0] maskA3;

always@(posedge iCLOCK) begin
  player3 <= player2;
  maskA3 <= maskA2;
end

wire [63:0] OF1;

assign OF1 = oUB & player3;

reg [63:0] F1;

always@(posedge iCLOCK) begin
  F1 <= ((-OF1) << 1) & maskA3;
end

reg [63:0] maskB;
reg [63:0] opponent3;

always@(posedge iCLOCK) begin
  maskB <= iMaskB << iPos;
  opponent3 <= iOpponent;
end

reg [63:0] OF2;
reg [63:0] maskB2;

always@(posedge iCLOCK) begin
  OF2 <= maskB & ((opponent3 | ~maskB) + 64'd1) & player2;
  maskB2 <= maskB;
end

wire isnonzero;

assign isnonzero = |OF2;

reg [63:0] F2;

always@(posedge iCLOCK) begin
  F2 <= (OF2 - isnonzero) & maskB2;
end

assign oFlip = F1 | F2;

endmodule
