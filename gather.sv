module gather
#(
  parameter int width = 40
)
(
  input clock,
  input reset,
  input wire [width-1:0] m0_data,
  input wire m0_valid,
  output wire m0_ready,
  input wire [width-1:0] m1_data,
  input wire m1_valid,
  output wire m1_ready,
  output wire [width-1:0] s_data,
  output wire s_valid,
  input wire s_ready
);

logic [width-1:0] buffer;
logic valid;
logic select;

assign s_data = buffer;
assign s_valid = valid;
assign m0_ready = !valid && select == 1'b0;
assign m1_ready = !valid && select == 1'b1;

always_ff@(posedge clock or posedge reset) begin
  if (reset) begin
    valid <= 1'b0;
    select <= 1'b0;
  end else begin
    if (s_valid && s_ready) begin
      valid <= 1'b0;
    end else if (!valid) begin
      if (m0_valid && m0_ready) begin
        buffer <= m0_data;
        valid <= 1'b1;
      end else if (m1_valid && m1_ready) begin
        buffer <= m1_data;
        valid <= 1'b1;
      end else begin
        valid <= 1'b0;
      end
    end else begin
      valid <= 1'b1;
    end
    select <= !select;
  end
end

endmodule