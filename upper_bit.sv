module upper_bit(
  input wire iCLOCK,
  input wire [63:0] i,
  output reg [63:0] o
);

wire [63:0] x1;
wire [63:0] x2;
wire [63:0] x3;
wire [63:0] x4;
wire [63:0] x5;

assign x1  = |(64'hFFFFFFFF00000000 &  i) == 1'b0 ?  i : ( i & 64'hFFFFFFFF00000000);
assign x2  = |(64'hFFFF0000FFFF0000 & x1) == 1'b0 ? x1 : (x1 & 64'hFFFF0000FFFF0000);
assign x3  = |(64'hFF00FF00FF00FF00 & x2) == 1'b0 ? x2 : (x2 & 64'hFF00FF00FF00FF00);
assign x4  = |(64'hF0F0F0F0F0F0F0F0 & x3) == 1'b0 ? x3 : (x3 & 64'hF0F0F0F0F0F0F0F0);
assign x5  = |(64'hCCCCCCCCCCCCCCCC & x4) == 1'b0 ? x4 : (x4 & 64'hCCCCCCCCCCCCCCCC);

always@(posedge iCLOCK)begin
  o <= |(64'hAAAAAAAAAAAAAAAA & x5) == 1'b0 ? x5 : (x5 & 64'hAAAAAAAAAAAAAAAA);
end

endmodule
