`timescale 1 ps / 1 ps
module processer_sim;

localparam PL_CYCLE = 20;

reg iCLOCK;
reg enable;
reg valid;
reg [63:0] iPlayer;
reg [63:0] iOpponent;
reg [15:0] iTaskid;
logic solved;
logic [15:0] oTaskid;
logic signed [7:0] res;
logic [2:0] o;
logic [2:0] pidx;

pipeline pipeline(
  .iCLOCK(iCLOCK),
  .valid(valid),
  .enable(enable),
  .iPlayer(iPlayer),
  .iOpponent(iOpponent),
  .iTaskid(iTaskid),
  .solved(solved),
  .oTaskid(oTaskid),
  .res(res),
  .o(o),
  .pidx(pidx));

integer i, j, k, fd, task_count;
bit [63:0] player[0:1000];
bit [63:0] opponent[0:1000];
bit signed [7:0] result[0:1000];
time stones;
task tsk_check;
  begin
    task_count = 1000;
    fd = $fopen("reference-pipeline.txt", "r");
    for (i = 0; i < task_count; i = i+1) begin
      $fscanf(fd, "%d %d %d", player[i], opponent[i], result[i]);
      //$display("%d %h %h %d", i, player[i], opponent[i], result[i]);
    end
    player[task_count] = 64'hffffffffffffffff;
    opponent[task_count] = 64'h0;
    result[task_count] = 16'h64;
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
    
    valid <= 1'b1;
    for (i = 0; i <= 8; i = i+1) begin
      iPlayer <= player[i];
      iOpponent <= opponent[i];
      iTaskid <= i;
      #PL_CYCLE;
    end
    k = 0;
    for (j = 0; j < task_count * 10000 && k < task_count; j = j+1) begin
      #PL_CYCLE;
      if (i > task_count) begin
        iPlayer <= 64'hffffffffffffffff;
        iOpponent <= 64'h0;
        iTaskid <= 64'hffff;
      end
      //$display("%d %d %d %d %d", j, iTaskid, oTaskid, i, k);
      if (solved == 1'b1) begin
        if (oTaskid < 16'hffff) begin
          $display("Solved: id=%d steps=%d P=%h O=%h res=%d ex=%d", oTaskid, j, player[oTaskid], opponent[oTaskid], res, result[oTaskid]);
          if (res != result[oTaskid]) begin
            $display("wrong answer");
            $finish;
          end else begin
            $display("collect answer");
          end
          k = k+1;
          if (i <= task_count) begin
            iPlayer <= player[i];
            iOpponent <= opponent[i];
            iTaskid <= i < task_count ? i : 16'hffff;
          end
          i = i+1;
        end
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
  iTaskid <= 16'hffff;

  #(PL_CYCLE * 5);
  $dumpfile("fpgaothello.vcd");
  $dumpvars(0, pipeline);

  tsk_check();
  
  $finish;
end

endmodule
