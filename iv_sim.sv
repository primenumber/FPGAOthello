`timescale 1 ps / 1 ps
module processer_sim;

localparam PL_CYCLE = 20;

reg clock;
reg reset;
reg [63:0] iPlayer;
reg [63:0] iOpponent;
reg [15:0] iTaskid;
logic solved;
logic [15:0] oTaskid;
logic signed [7:0] res;
logic [15:0] oNodes;

logic [39:0] output_data;
logic output_valid;
logic output_ready;
feed feed(
  .clock(clock),
  .reset(reset),
  .input_data({iPlayer, iOpponent, iTaskid}),
  .input_valid(input_valid),
  .input_ready(input_ready),
  .output_data(output_data),
  .output_valid(output_valid),
  .output_ready(output_ready)
);

assign {res, oTaskid, oNodes} = output_data;
assign input_valid = 1'b1;
assign output_ready = 1'b1;
assign solved = output_valid;

integer i, j, k, fd, task_count, nodes_sum;
bit [63:0] player[0:1000];
bit [63:0] opponent[0:1000];
bit signed [7:0] result[0:1000];
time stones;
task tsk_check;
  begin
    task_count = 1000;
    nodes_sum = 0;
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
    end
    
    $display("!!!!!start!!!!!");
    
    reset <= 1'b0;
    
    for (i = 0; i < 8; i=i) begin
      if (input_ready) begin
        iPlayer <= player[i];
        iOpponent <= opponent[i];
        iTaskid <= i;
        i = i+1;
      end
      #PL_CYCLE;
    end
    k = 0;
    for (j = 0; j < task_count * 10000 && k < task_count; j = j+1) begin
      if (i > task_count) begin
        iPlayer <= 64'hffffffffffffffff;
        iOpponent <= 64'h0;
        iTaskid <= 64'hffff;
      end
      //$display("%d %d %d %d %d", j, iTaskid, oTaskid, i, k);
      if (solved == 1'b1) begin
        if (oTaskid < 16'hffff) begin
          nodes_sum += oNodes;
          $display("Solved: id=%d steps=%d P=%h O=%h res=%d ex=%d nodes=%d (sum=%d)", oTaskid, j, player[oTaskid], opponent[oTaskid], res, result[oTaskid], oNodes, nodes_sum);
          if (res != result[oTaskid]) begin
            $display("wrong answer");
            $finish;
          end else begin
            $display("collect answer");
          end
          k = k+1;
        end
      end
      if (input_ready) begin
        if (i <= task_count) begin
          iPlayer <= player[i];
          iOpponent <= opponent[i];
          iTaskid <= i < task_count ? i : 16'hffff;
        end
        i = i+1;
      end
      #PL_CYCLE;
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
  reset = 1'b1;
  iPlayer <= 64'hffffffffffffffff;
  iOpponent <= 64'h0;
  iTaskid <= 16'hffff;

  #(PL_CYCLE * 5);
  $dumpfile("fpgaothello.vcd");
  $dumpvars(0, feed);

  tsk_check();
  
  $finish;
end

endmodule
