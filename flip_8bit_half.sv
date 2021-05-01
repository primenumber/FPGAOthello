module flip8_upper(
  input wire [7:0] player,
  input wire [7:0] opponent,
  input wire [2:0] pos,
  output wire [7:0] flip
);

wire [7:0] mask = 8'hff >> (3'h7 ^ pos);
wire [7:0] o_upper = opponent | mask;
wire [7:0] flip_end = player & (o_upper + 1);

assign flip = (flip_end - |flip_end) & ~mask;

endmodule
