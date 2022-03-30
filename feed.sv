module feed(
    input clock,
    input reset,
    input wire [143:0] input_data,
    input wire input_valid,
    output wire input_ready,
    output wire [39:0] output_data,
    output wire output_valid,
    input wire output_ready,
    output wire [3:0] count
    );

logic [143:0] input_buffer;
logic input_buffer_valid;
logic solved;
logic [39:0] output_buffer;
logic output_buffer_valid;
logic [3:0] fifo_count;
logic [63:0] i_player;
logic [63:0] i_opponent;
logic [15:0] i_taskid;
logic [7:0] o_result;
logic [15:0] o_taskid;
logic [15:0] o_nodes;
logic fifo_ren;
logic fifo_wen;

assign {i_player, i_opponent, i_taskid} = input_buffer;
assign output_buffer = {o_result, o_taskid, o_nodes};
assign input_ready = !input_buffer_valid && count < 4;
assign count = fifo_count;

always_ff@(posedge clock or posedge reset) begin
  if (reset) begin
    input_buffer_valid <= 1'b0;
    input_buffer <= 144'hffffffffffffffffffffffffffffffffffff;
  end else begin
    if (input_ready && input_valid) begin
      input_buffer_valid <= 1'b1;
      input_buffer <= input_data;
    end else if (solved) begin
      input_buffer_valid <= 1'b0;
      input_buffer <= input_buffer;
    end else begin
      input_buffer_valid <= input_buffer_valid;
      input_buffer <= input_buffer;
    end
  end
end

pipeline pipeline(
  .iCLOCK(clock),
  .valid(input_buffer_valid),
  .enable(~reset),
  .iPlayer(i_player),
  .iOpponent(i_opponent),
  .iTaskid(i_taskid),
  .solved(solved),
  .oTaskid(o_taskid),
  .res(o_result),
  .oNodes(o_nodes)
);

assign fifo_ren = output_ready && output_valid;
assign output_valid = fifo_count != 0;
assign fifo_wen = solved;

fifo #(.width(40), .addr_bits(3)) o_fifo(
  .clock(clock),
  .reset(reset),
  .ren(fifo_ren),
  .rdata(output_data),
  .wen(fifo_wen),
  .wdata(output_buffer),
  .count(fifo_count)
);

endmodule