`timescale 1 ps / 1 ps
module test_flip_v2;

localparam PL_CYCLE = 10;

reg iCLOCK;
reg [63:0] iPlayer;
reg [63:0] iOpponent;
reg [5:0] pos;
reg [63:0] flip_expected;
reg [63:0] flip_result;
reg [63:0] flip_old;

flip flip(
  .iCLOCK(iCLOCK),
  .iPlayer(iPlayer),
  .iOpponent(iOpponent),
  .iPos(pos),
  .oFlip(flip_old));

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
    
    for (i = 0; i < 5000; i = i+1) begin
      $fscanf(fd, "%d %d %d %d", iPlayer, iOpponent, pos, flip_expected);
      #PL_CYCLE;
      #PL_CYCLE;
      #PL_CYCLE;
      #PL_CYCLE;
      if (flip_result != flip_old) begin
        $display("!!!!!ERROR!!!!!");
        $display("%h %h %d %h %h", iPlayer, iOpponent, pos, flip_result, flip_expected);
      end
    end
//    //iPlayer <= 64'h10B8DDE3B1B98284;
//    //iOpponent <= 64'h8E45221C4E467C78;
//    //expected <= 16;
//    //iPlayer <= 64'h001F03070B15FF01;
//    //iOpponent <= 64'h7F207CF8F4EA00FE;
//    //expected <= 14;
//    iPlayer <= 64'hBF8387EBB3F8C002;
//    iOpponent <= 64'h407C78144C073F3D;
//    //expected <= 2;
//
//    //for (i = 0; i < 8; i = i+1) begin
//    //  #PL_CYCLE;
//    //  $display("%h", o);
//    //end
//    
//    #PL_CYCLE;
//    $display("!!!!!start!!!!!");
//    stones = iPlayer | iOpponent;
//    $display("%h", stones);
//    
//    $display("%b %b", iPlayer[7:0],   iOpponent[7:0]);
//    $display("%b %b", iPlayer[15:8],  iOpponent[15:8]);
//    $display("%b %b", iPlayer[23:16], iOpponent[23:16]);
//    $display("%b %b", iPlayer[31:24], iOpponent[31:24]);
//    $display("%b %b", iPlayer[39:32], iOpponent[39:32]);
//    $display("%b %b", iPlayer[47:40], iOpponent[47:40]);
//    $display("%b %b", iPlayer[55:48], iOpponent[55:48]);
//    $display("%b %b", iPlayer[63:56], iOpponent[63:56]);
//    
//    for (i = 0; i < 64; i = i+1) begin
//      pos <= i;
//      #PL_CYCLE;
//      #PL_CYCLE;
//      #PL_CYCLE;
//      #PL_CYCLE;
//      if (flip_result != flip_expected) begin
//        $display("ERROR %d", i);
//        $display("%b %b", flip_expected[7:0],   flip_result[7:0]);
//        $display("%b %b", flip_expected[15:8],  flip_result[15:8]);
//        $display("%b %b", flip_expected[23:16], flip_result[23:16]);
//        $display("%b %b", flip_expected[31:24], flip_result[31:24]);
//        $display("%b %b", flip_expected[39:32], flip_result[39:32]);
//        $display("%b %b", flip_expected[47:40], flip_result[47:40]);
//        $display("%b %b", flip_expected[55:48], flip_result[55:48]);
//        $display("%b %b", flip_expected[63:56], flip_result[63:56]);
//      end
//    end
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

