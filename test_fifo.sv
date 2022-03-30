`timescale 1 ps / 1 ps
module test_fifo;

localparam PL_CYCLE = 10;

reg clock;
reg reset;
reg ren;
reg [39:0] rdata;
reg wen;
reg [39:0] wdata;
reg [3:0] count;

fifo fifo(
  .clock(clock),
  .reset(reset),
  .ren(ren),
  .rdata(rdata),
  .wen(wen),
  .wdata(wdata),
  .count(count));

task task_test;
  begin
    #PL_CYCLE;
    reset <= 1'b0;
    wen <= 1'b1;
    wdata <= 40'h123456789a;
    #PL_CYCLE;
    $display("%h %h", count, rdata);
    wdata <= 40'h23456789ab;
    #PL_CYCLE;
    $display("%h %h", count, rdata);
    wdata <= 40'h3456789abc;
    ren <= 1'b1;
    #PL_CYCLE;
    wen <= 1'b0;
    $display("%h %h", count, rdata);
    #PL_CYCLE;
    $display("%h %h", count, rdata);
    #PL_CYCLE;
    $display("%h %h", count, rdata);
    wen <= 1'b1;
    wdata <= 40'h456789abcd;
    #PL_CYCLE;
    $display("%h %h", count, rdata);
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
  reset = 1'b1;
  wen = 1'b0;
  ren = 1'b0;

  #(PL_CYCLE * 5);
  $dumpfile("fifo-test.vcd");
  $dumpvars(0, fifo);

  task_test();
  
  $finish;
end

endmodule
