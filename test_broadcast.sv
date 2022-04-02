`timescale 1 ps / 1 ps
module test_broadcast;

localparam PL_CYCLE = 10;
localparam WIDTH = 8;

reg clock;
reg reset;
logic [WIDTH-1:0] i_data;
logic i_valid;
logic i_ready;
logic [WIDTH-1:0] o0_data;
logic o0_valid;
logic o0_ready;
logic [WIDTH-1:0] o1_data;
logic o1_valid;
logic o1_ready;

broadcast#(.width(WIDTH)) broadcast(
  .clock(clock),
  .reset(reset),
  .m_data(i_data),
  .m_valid(i_valid),
  .m_ready(i_ready),
  .s0_data(o0_data),
  .s0_valid(o0_valid),
  .s0_ready(o0_ready),
  .s1_data(o1_data),
  .s1_valid(o1_valid),
  .s1_ready(o1_ready)
);

int cnt, j;
always_ff@(posedge clock or posedge reset) begin
  if (reset) begin
    cnt <= 0;
    j <= 0;
  end else begin
    if (i_ready && i_valid) begin
      i_data <= j;
      j <= j + 1;
    end
    if (cnt % 3 == 0) begin
      o0_ready <= 1'b0;
    end else begin
      o0_ready <= 1'b1;
    end
    if (cnt % 4 == 0) begin
      o1_ready <= 1'b0;
    end else begin
      o1_ready <= 1'b1;
    end
    if (cnt % 5 == 0) begin
      i_valid <= 1'b0;
    end else begin
      i_valid <= 1'b1;
    end
    cnt <= cnt+1;
  end
end

int i;
task task_test;
  begin
    #PL_CYCLE;
    reset <= 1'b0;
    for (i = 0; i < 100; i = i+1) begin
      #PL_CYCLE;
      $display("%h %b %b %h %b %b %h %b %b", i_data, i_valid, i_ready, o0_data, o0_valid, o0_ready, o1_data, o1_valid, o1_ready);
      if (o0_valid && o0_ready) begin
        $display("Receive Core0: %h", o0_data);
      end
      if (o1_valid && o1_ready) begin
        $display("Receive Core1: %h", o1_data);
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
  $dumpfile("broadcast.vcd");
  $dumpvars(0, broadcast);

  task_test();
  
  $finish;
end

endmodule
