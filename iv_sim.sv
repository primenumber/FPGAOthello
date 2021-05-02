`timescale 1 ps / 1 ps
module processer_sim;

localparam PL_CYCLE = 20;

reg iCLOCK;
reg enable;
reg valid;
reg [63:0] iPlayer;
reg [63:0] iOpponent;
logic signed [7:0] expected;
logic solved;
logic [63:0] oPlayer;
logic [63:0] oOpponent;
logic signed [7:0] res;
logic [2:0] o;
logic [2:0] pidx;

pipeline pipeline(
  .iCLOCK(iCLOCK),
  .valid(valid),
  .enable(enable),
  .iPlayer(iPlayer),
  .iOpponent(iOpponent),
  .solved(solved),
  .oPlayer(oPlayer),
  .oOpponent(oOpponent),
  .res(res),
  .o(o),
  .pidx(pidx));

integer i, j, k, fd, finished;
time stones;
task tsk_check;
  begin
    fd = $fopen("reference-pipeline.txt", "r");
    //iPlayer <= 64'h10B8DDE3B1B98284;
    //iOpponent <= 64'h8E45221C4E467C78;
    //expected <= 16;
    //iPlayer <= 64'h001F03070B15FF01;
    //iOpponent <= 64'h7F207CF8F4EA00FE;
    //expected <= 14;
    //iPlayer <= 64'hBF8387EBB3F8C002;
    //iOpponent <= 64'h407C78144C073F3D;
    //expected <= 2;

    for (i = 0; i < 8; i = i+1) begin
      #PL_CYCLE;
      $display("%h", o);
    end
    
    $display("!!!!!start!!!!!");
    
    enable <= 1'b1;
    
    for (i = 0; i < 100; i = i+1) begin
      //iPlayer <= 64'h1e8c8c74f2cefa08;
      //iOpponent <= 64'he173738b0d0101f5;
      //expected <= -8;
      //iPlayer <= 64'hffffffffffffffff;
      //iOpponent <= 64'h0;
      //expected <= 8'd64;
      $fscanf(fd, "%d %d %d", iPlayer, iOpponent, expected);
      valid <= 1'b1;
      #(PL_CYCLE * 8);
      valid <= 1'b0;
      $display("To solve: ID=%d P=%h O=%h E=%h res=%d", i, iPlayer, iOpponent, ~(iPlayer | iOpponent), expected);
      finished = 0;
      for (j = 0; j < 100000 && !finished; j = j+1) begin
        #PL_CYCLE;
        //$display("%d %d %d %d %b", i, j, o, pidx, solved);
        if (solved == 1'b1) begin
          if (oPlayer == iPlayer && oOpponent == iOpponent) begin
            $display("Solved: steps=%d P=%h O=%h res=%d ex=%d %d", j, oPlayer, oOpponent, res, expected, o);
            if (res != expected) begin
              $display("wrong answer");
              $finish;
            end else begin
              $display("collect answer");
              finished = 1;
            end
          end
        end
      end
      if (!finished) begin
        $display("not solved!");
        $finish;
      end
      k = 0;
      for (j = 0; j < k + 8; j = j+1) begin
        #PL_CYCLE;
        if (solved == 1'b0) begin
          k = j;
        end
        //$display("%d %d", j, k);
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
  enable = 1'b0;
  iPlayer <= 64'hffffffffffffffff;
  iOpponent <= 64'h0;
  expected <= 8'h64;

  #(PL_CYCLE * 5);
  $dumpfile("fpgaothello.vcd");
  $dumpvars(0, pipeline);

  tsk_check();
  
  $finish;
end

endmodule
