`timescale 1 ps / 1 ps
module test_gather;

localparam PL_CYCLE = 10;
localparam WIDTH = 8;

reg clock;
reg reset;
logic [WIDTH-1:0] i0_data;
logic i0_valid;
logic i0_ready;
logic [WIDTH-1:0] i1_data;
logic i1_valid;
logic i1_ready;
logic [WIDTH-1:0] o_data;
logic o_valid;
logic o_ready;

gather#(.width(WIDTH)) gather(
  .clock(clock),
  .reset(reset),
  .m0_data(i0_data),
  .m0_valid(i0_valid),
  .m0_ready(i0_ready),
  .m1_data(i1_data),
  .m1_valid(i1_valid),
  .m1_ready(i1_ready),
  .s_data(o_data),
  .s_valid(o_valid),
  .s_ready(o_ready)
);

int i,j,k;
always_ff@(posedge clock or posedge reset) begin
  if (reset) begin
    i <= 0;
    j <= 1;
    k <= 1;
    i0_data <= 8'h80;
    i1_data <= 8'h00;
    i0_valid <= 1'b0;
    i1_valid <= 1'b0;
  end else begin
    i <= i + 1;
    if (i0_ready && i0_valid) begin
      i0_data <= j | 8'h80;
      j <= j + 1;
    end
    if (i1_ready && i1_valid) begin
      i1_data <= k;
      k <= k + 1;
    end
    if (i % 3 == 0) begin
      i0_valid <= 1'b0;
    end else begin
      i0_valid <= 1'b1;
    end
    if (i % 4 == 0) begin
      i1_valid <= 1'b0;
    end else begin
      i1_valid <= 1'b1;
    end
    if (i % 5 == 0) begin
      o_ready <= 1'b0;
    end else begin
      o_ready <= 1'b1;
    end
  end
end

int count;
task task_test;
  begin
    #PL_CYCLE;
    reset <= 1'b0;
    for (count = 0; count < 100; count = count + 1) begin
      #PL_CYCLE;
      $display("%h %b %b %h %b %b %h %b %b", i0_data, i0_valid, i0_ready, i1_data, i1_valid, i1_ready, o_data, o_valid, o_ready);
      if (o_ready && o_valid) begin
        $display("received: %h", o_data);
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
  reset = 1'b1;

  #(PL_CYCLE * 5);
  $dumpfile("gather.vcd");
  $dumpvars(0, gather);

  task_test();
  
  $finish;
end

endmodule