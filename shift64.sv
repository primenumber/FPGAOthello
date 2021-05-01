module shift64(
  input wire [63:0] x,
  input wire [3:0] shift,
  output wire [63:0] y
);

function [7:0] extended_shift8;
  input [7:0] x;
  input [3:0] shift;
begin
  extended_shift8 = {x, 8'h0} >> shift;
end
endfunction

assign y = {
  extended_shift8(x[63:56], shift),
  extended_shift8(x[55:48], shift),
  extended_shift8(x[47:40], shift),
  extended_shift8(x[39:32], shift),
  extended_shift8(x[31:24], shift),
  extended_shift8(x[23:16], shift),
  extended_shift8(x[15:8], shift),
  extended_shift8(x[7:0], shift)
};

endmodule
