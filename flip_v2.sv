module flip_v2(
  input wire clock,
  input wire [63:0] player,
  input wire [63:0] opponent,
  input wire [5:0] pos,
  output reg [63:0] flip
);

wire [2:0] row = pos[5:3];
wire [2:0] col = pos[2:0];
wire [2:0] icol = ~col;

wire [7:0] player_v;
wire [7:0] opponent_v;

extract_v ext_p_v(
  .x(player),
  .shift(col),
  .y(player_v));

extract_v ext_o_v(
  .x(opponent),
  .shift(col),
  .y(opponent_v));

wire [63:0] player_s = player >> {row, 3'b0};
wire [63:0] opponent_s = opponent >> {row, 3'b0};
wire [7:0] player_h = player_s[7:0];
wire [7:0] opponent_h = opponent_s[7:0];

wire [3:0] shift_a1h8 = col + 8 - row;
wire [7:0] player_a1h8;
wire [7:0] opponent_a1h8;

extract_a1h8 ext_p_a1h8(
  .x(player),
  .shift(shift_a1h8),
  .y(player_a1h8));

extract_a1h8 ext_o_a1h8(
  .x(opponent),
  .shift(shift_a1h8),
  .y(opponent_a1h8));

wire [3:0] shift_a8h1 = row + col + 1;
wire [7:0] player_a8h1;
wire [7:0] opponent_a8h1;

extract_a8h1 ext_p_a8h1(
  .x(player),
  .shift(shift_a8h1),
  .y(player_a8h1));

extract_a8h1 ext_o_a8h1(
  .x(opponent),
  .shift(shift_a8h1),
  .y(opponent_a8h1));

logic [7:0] flip_v;
logic [7:0] flip_h;
logic [7:0] flip_a1h8;
logic [7:0] flip_a8h1;

flip8 f8v(
  .clock(clock),
  .player(player_v),
  .opponent(opponent_v),
  .pos(row),
  .flip(flip_v));

flip8 f8h(
  .clock(clock),
  .player(player_h),
  .opponent(opponent_h),
  .pos(col),
  .flip(flip_h));

flip8 f8a1(
  .clock(clock),
  .player(player_a1h8),
  .opponent(opponent_a1h8),
  .pos(row),
  .flip(flip_a1h8));
  
flip8 f8a8(
  .clock(clock),
  .player(player_a8h1),
  .opponent(opponent_a8h1),
  .pos(row),
  .flip(flip_a8h1));

function [63:0] scatter_v;
  input [7:0] x;
begin
  scatter_v = {
    7'h0, x[7], 
    7'h0, x[6], 
    7'h0, x[5], 
    7'h0, x[4], 
    7'h0, x[3], 
    7'h0, x[2], 
    7'h0, x[1], 
    7'h0, x[0]
  };
end
endfunction

function [63:0] scatter_a1h8;
  input [7:0] x;
begin
  scatter_a1h8 = {
    x[7],
    8'h0, x[6], 
    8'h0, x[5], 
    8'h0, x[4], 
    8'h0, x[3], 
    8'h0, x[2], 
    8'h0, x[1], 
    8'h0, x[0]
  };
end
endfunction

function [63:0] scatter_a8h1;
  input [7:0] x;
begin
  scatter_a8h1 = {
    7'h0, x[7], 
    6'h0, x[6], 
    6'h0, x[5], 
    6'h0, x[4], 
    6'h0, x[3], 
    6'h0, x[2], 
    6'h0, x[1], 
    6'h0, x[0],
    7'h0
  };
end
endfunction

reg [3:0] rev_shift_a1h8;
reg [3:0] rev_shift_a8h1;
reg [5:0] pos_reg;

always@(posedge clock) begin
  rev_shift_a1h8 <= 16 - shift_a1h8;
  rev_shift_a8h1 <= 16 - shift_a8h1;
  pos_reg <= pos;
end
wire [63:0] a1h8;
wire [63:0] a8h1;
wire [63:0] v;

shift64 rshift_a1h8(
  .x(scatter_a1h8(flip_a1h8)),
  .shift(rev_shift_a1h8),
  .y(a1h8));

shift64 rshift_a8h1(
  .x(scatter_a8h1(flip_a8h1)),
  .shift(rev_shift_a8h1),
  .y(a8h1));

shift64 rshift_v(
  .x(scatter_v(flip_v)),
  .shift(4'h8 - pos_reg[2:0]),
  .y(v));

always@(posedge clock) begin
  flip <= flip_h << {pos_reg[5:3], 3'h0} | v | a1h8 | a8h1;
end

endmodule
