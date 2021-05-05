module flip8(
  input wire clock,
  input wire [7:0] player,
  input wire [7:0] opponent,
  input wire [2:0] pos,
  output reg [7:0] flip_upper,
  output reg [7:0] flip_lower
);

function [7:0] rev8;
  input [7:0] x;
begin
  rev8 = {x[0], x[1], x[2], x[3], x[4], x[5], x[6], x[7]};
end
endfunction

logic [7:0] flip_upper_w;
logic [7:0] flip_lower_w;

flip8_upper f8_upper(
  .player(player),
  .opponent(opponent),
  .pos(pos),
  .flip(flip_upper_w));

flip8_upper f8_lower(
  .player(rev8(player)),
  .opponent(rev8(opponent)),
  .pos(3'h7 - pos),
  .flip(flip_lower_w));

always@(posedge clock)begin
  flip_upper <= flip_upper_w;
  flip_lower <= flip_lower_w;
end

endmodule
