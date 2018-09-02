`default_nettype none

module fpgaOthello(
  input wire CLOCK_50,
  input wire RESET_N,
  output wire [4:0] LEDR
);

wire res_n;
reg por_n; // should be power-up level = Low
reg [23:0] por_count; // should be power-up level = Low
wire solved;
wire signed [7:0] res;

processer PROC(
  .*,
  .iCLOCK(CLOCK_50),
  .enable(res_n),
  .iPlayer(64'h0018247A32464800),
  .iOpponent(64'h3E255B854D39357E),
  .o(LEDR)
);

always@(posedge CLOCK_50, negedge RESET_N) begin
  if (~RESET_N) begin
    por_count = 0;
  end else if (por_count != 24'hFFFFFF) begin
    por_n <= 1'b0;
    por_count <= por_count + 24'h000001;
  end else begin
    por_n <= 1'b1;
    por_count <= por_count;
  end
end

assign res_n = por_n;

endmodule
