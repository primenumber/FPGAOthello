`timescale 1 ps / 1 ps
module processer_sim;

localparam PL_CYCLE = 20;

reg iCLOCK;
reg enable;
reg [63:0] iPlayer;
reg [63:0] iOpponent;
logic signed [7:0] expected;
logic solved;
logic [63:0] oPlayer;
logic [63:0] oOpponent;
logic signed [7:0] res;
logic [4:0] o;

pipeline pipeline(
  .iCLOCK(iCLOCK),
  .enable(enable),
  .iPlayer(iPlayer),
  .iOpponent(iOpponent),
  .solved(solved),
  .oPlayer(oPlayer),
  .oOpponent(oOpponent),
  .res(res),
  .o(o));

integer i, j;
time stones;
task tsk_check;
  begin
    //iPlayer <= 64'h10B8DDE3B1B98284;
    //iOpponent <= 64'h8E45221C4E467C78;
    //expected <= 16;
    iPlayer <= 64'h001F03070B15FF01;
    iOpponent <= 64'h7F207CF8F4EA00FE;
    expected <= 14;
    //iPlayer <= 64'hBF8387EBB3F8C002;
    //iOpponent <= 64'h407C78144C073F3D;
    //expected <= 2;

    for (i = 0; i < 8; i = i+1) begin
      #PL_CYCLE;
      $display("%h", o);
    end
    
    $display("!!!!!start!!!!!");
    stones = iPlayer | iOpponent;
    $display("%h", stones);
    
    enable <= 1'b1;
    
    for (i = 0; i < 300000; i = i+1) begin
      #PL_CYCLE;
      $display("%d %d", i, o);
      if (solved == 1'b1) begin
        $display("solved!");
        $display("%h %h %d %d", oPlayer, oOpponent, res, o);
        if (res != expected) begin
          $display("wrong answer");
        end else begin
          $display("collect answer");
        end
        $finish;
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
  enable = 1'b0;

  #(PL_CYCLE * 5);
  $dumpfile("fpgaothello.vcd");
  $dumpvars(0, pipeline);

  tsk_check();
  
  $finish;
end

endmodule
