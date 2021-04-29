module extract_a8h1(
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

assign y = {tmp[56], tmp[49], tmp[42], tmp[35], tmp[28], tmp[21], tmp[14], tmp[7]};

endmodule


