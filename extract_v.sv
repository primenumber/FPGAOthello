module extract_v(
  input wire [63:0] x,
  input wire [2:0] shift,
  output wire [7:0] y
);

wire [63:0] tmp = x >> shift;
assign y = {tmp[56], tmp[48], tmp[40], tmp[32], tmp[24], tmp[16], tmp[8], tmp[0]};

endmodule
