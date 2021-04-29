module extract_a1h8(
  input wire [63:0] x,
  input wire [2:0] shift,
  input wire shift_dir,
  output wire [7:0] y
);

wire [63:0] tmp;

shift64 shift64(
  .x(x),
  .shift(shift),
  .shift_dir(shift_dir),
  .y(tmp));
assign y = {tmp[63], tmp[54], tmp[45], tmp[36], tmp[27], tmp[18], tmp[9], tmp[0]};

endmodule

