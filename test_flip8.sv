`timescale 1 ps / 1 ps
module test_flip8;

localparam PL_CYCLE = 10;

reg clock;
logic [7:0] player;
logic [7:0] opponent;
logic [2:0] pos;
logic [7:0] flip_u;
logic [7:0] flip_l;
logic [7:0] expected;

function [7:0] rev8;
  input [7:0] x;
begin
  rev8 = {x[0], x[1], x[2], x[3], x[4], x[5], x[6], x[7]};
end
endfunction

flip8 flip8(
  .clock(clock),
  .player(player),
  .opponent(opponent),
  .pos(pos),
  .flip_upper(flip_u),
  .flip_lower(flip_l));

wire [7:0] flip = flip_u | rev8(flip_l);
integer i, j, fd;
task task_test;
  begin
    fd = $fopen("reference-flip8.txt", "r");
    
    for (i = 0; i < 17496; i = i+1) begin
      $fscanf(fd, "%d %d %d %d", player, opponent, pos, expected);
      #PL_CYCLE;
      if (flip != expected) begin
        $display("!!!!!ERROR!!!!!");
        $display("%h %h %d %h %h", player, opponent, pos, flip, expected);
      end
    end
  end
endtask

initial begin
  clock = 1'b0;
  forever begin
    #(PL_CYCLE / 2) clock = ~clock;
  end
end

initial begin
  clock = 1'b0;

  #(PL_CYCLE * 5);
  $dumpfile("flip8-test.vcd");
  $dumpvars(0, flip8);

  task_test();
  
  $finish;
end

endmodule
