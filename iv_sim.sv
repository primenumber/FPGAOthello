`timescale 1 ps / 1 ps
module processer_sim;

localparam PL_CYCLE = 20;

reg iCLOCK;
reg enable;
reg valid;
reg [63:0] iPlayer;
reg [63:0] iOpponent;
reg [63:0] iPlayer0;
reg [63:0] iOpponent0;
logic signed [7:0] expected0;
reg [63:0] iPlayer1;
reg [63:0] iOpponent1;
logic signed [7:0] expected1;
logic solved;
logic [63:0] oPlayer;
logic [63:0] oOpponent;
logic signed [7:0] res;
logic [2:0] o;

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
  .o(o));

reg parity;

integer i, j;
time stones;
task tsk_check;
  begin
    //iPlayer0 <= 64'h10B8DDE3B1B98284;
    //iOpponent0 <= 64'h8E45221C4E467C78;
    //expected0 <= 16;
    iPlayer1 <= 64'h10B8DDE3B1B98284;
    iOpponent1 <= 64'h8E45221C4E467C78;
    expected1 <= 16;
    iPlayer0 <= 64'h001F03070B15FF01;
    iOpponent0 <= 64'h7F207CF8F4EA00FE;
    expected0 <= 14;
    //iPlayer1 <= 64'h001F03070B15FF01;
    //iOpponent1 <= 64'h7F207CF8F4EA00FE;
    //expected1 <= 14;
    //iPlayer1 <= 64'hBF8387EBB3F8C002;
    //iOpponent1 <= 64'h407C78144C073F3D;
    //expected1 <= 2;

    for (i = 0; i < 8; i = i+1) begin
      #PL_CYCLE;
      $display("%h", o);
    end
    
    $display("!!!!!start!!!!!");
    //stones = iPlayer | iOpponent;
    $display("B0: %h %h", iPlayer0, iOpponent0);
    $display("B1: %h %h", iPlayer1, iOpponent1);
    
    enable <= 1'b1;
    valid <= 1'b1;
    #PL_CYCLE;
    $display("B: %h %h", iPlayer, iOpponent);
    
    for (i = 0; i < 300000; i = i+1) begin
      #PL_CYCLE;
      $display("%d %d", i, o);
      if (solved == 1'b1) begin
        $display("solved!");
        $display("%h %h %d %d", oPlayer, oOpponent, res, o);
        if (res != expected0 && res != expected1) begin
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
  forever begin
    #PL_CYCLE;
    if (parity) begin
      iPlayer <= iPlayer1;
      iOpponent <= iOpponent1;
    end else begin
      iPlayer <= iPlayer0;
      iOpponent <= iOpponent0;
    end
    parity <= ~parity;
  end
end

initial begin
  iCLOCK = 1'b0;
  parity = 1'b1;
  forever begin
    #(PL_CYCLE / 2) iCLOCK = ~iCLOCK;
  end
end

initial begin
  enable = 1'b0;

  #(PL_CYCLE * 5);
  $dumpfile("fpgaothello.vcd");
  $dumpvars(0, pipeline);

  tsk_check();
  
  $finish;
end

endmodule
