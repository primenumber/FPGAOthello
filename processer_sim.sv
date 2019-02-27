`timescale 1 ps / 1 ps
module processer_sim;

localparam PL_CYCLE = 20;

reg iCLOCK;
reg enable;
reg [63:0] iPlayer;
reg [63:0] iOpponent;
wire solved;
reg [4:0] o;
wire [63:0] oPlayer;
wire [63:0] oOpponent;
wire signed [7:0] res;

pipeline TARGET(
  .*
);

always#(PL_CYCLE/2) begin
  iCLOCK = !iCLOCK;
end

default clocking clk@(posedge iCLOCK);
endclocking

integer i, j;
time stones;
task tsk_check;
  begin
    iPlayer <= 64'h10B8DDE3B1B98284; // 16
    iOpponent <= 64'h8E45221C4E467C78;
    //iPlayer <= 64'h001F03070B15FF01; // 14
    //iOpponent <= 64'h7F207CF8F4EA00FE;
    //iPlayer <= 64'hBF8387EBB3F8C002; // 2
    //iOpponent <= 64'h407C78144C073F3D;

    for (i = 0; i < 5; i = i+1) begin
      ##1;
      $display("%h", o);
    end
    
    $display("!!!!!start!!!!!");
    stones = iPlayer | iOpponent;
    $display("%h", stones);
    
    enable <= 1'b1;
    
    for (i = 0; i < 10000000; i = i+1) begin
      ##1;
      $display("%d %h %d", i, o, res);
      if (solved == 1'b1) begin
        $display("solved!");
        $display("%h %h %d", oPlayer, oOpponent, res);
        if (res != 16) begin
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
  enable = 1'b0;
  
  ##5;
  
  tsk_check();
  
  $display("more than 10000000 cycle");
  $finish;
end

endmodule
