module score(
  input wire [63:0] iPlayer,
  input wire [63:0] iOpponent,
  output wire signed [7:0] o
);

reg [7:0] pcnt;
reg [7:0] ocnt;

popcount PCNT(
  .x(iPlayer),
  .o(pcnt[5:0])
);

popcount OCNT(
  .x(iOpponent),
  .o(ocnt[5:0])
);

assign o = pcnt == ocnt ? 0 : (pcnt > ocnt ? 8'd64 - (ocnt << 1) : -8'd64 + (pcnt << 1));

initial begin
  pcnt <= 0;
  ocnt <= 0;
end
endmodule
