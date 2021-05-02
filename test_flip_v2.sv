`timescale 1 ps / 1 ps
module test_flip_v2;

localparam PL_CYCLE = 10;

reg iCLOCK;
reg [63:0] iPlayer;
reg [63:0] iOpponent;
reg [5:0] pos;
reg [63:0] flip_expected;
reg [63:0] flip_result;

flip_v2 flip_v2(
  .clock(iCLOCK),
  .player(iPlayer),
  .opponent(iOpponent),
  .pos(pos),
  .flip(flip_result));

integer i, fd;
time stones;
task tsk_check;
  begin
    fd = $fopen("reference-flip.txt", "r");
    
    for (i = 0; i < 100000; i = i+1) begin
      $fscanf(fd, "%d %d %d %d", iPlayer, iOpponent, pos, flip_expected);
      #PL_CYCLE;
      #PL_CYCLE;
      if (flip_result != flip_expected) begin
        $display("!!!!!ERROR!!!!!");
        $display("%h %h %d %h %h", iPlayer, iOpponent, pos, flip_result, flip_expected);
      end
    end
  end
endtask

initial begin
  iCLOCK = 1'b0;
  forever begin
    #(PL_CYCLE / 2) iCLOCK = ~iCLOCK;
  end
end

initial begin
  iCLOCK = 1'b0;

  #(PL_CYCLE * 5);
  $dumpfile("flip-test.vcd");
  $dumpvars(0, flip_v2);

  tsk_check();
  
  $finish;
end

endmodule

