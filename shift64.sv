module shift64(
  input wire [63:0] x,
  input wire [2:0] shift,
  input wire shift_dir,
  output wire [63:0] y
);

function [7:0] shift8;
  input [7:0] x;
  input [2:0] shift;
  input shift_dir;
begin
  shift8 = shift_dir ? x >> shift : x << shift;
end
endfunction

function [63:0] mask64;
  input [2:0] shift;
  input shift_dir;
begin
  mask64 = {
    shift8(8'hff, shift, shift_dir),
    shift8(8'hff, shift, shift_dir),
    shift8(8'hff, shift, shift_dir),
    shift8(8'hff, shift, shift_dir),
    shift8(8'hff, shift, shift_dir),
    shift8(8'hff, shift, shift_dir),
    shift8(8'hff, shift, shift_dir),
    shift8(8'hff, shift, shift_dir)
  };
end
endfunction

assign y = (shift_dir ? x >> shift : x << shift) & mask64(shift, shift_dir);

endmodule
