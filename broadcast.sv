module broadcast
#(
  parameter int width = 160
)
(
  input clock,
  input reset,
  input wire [width-1:0] m_data,
  input wire m_valid,
  output wire m_ready,
  output wire [width-1:0] s0_data,
  output wire s0_valid,
  input wire s0_ready,
  output wire [width-1:0] s1_data,
  output wire s1_valid,
  input wire s1_ready 
);

logic [width-1:0] buffer;
logic valid;
logic select;

assign m_ready = !valid;
assign s0_data = buffer;
assign s1_data = buffer;
assign s0_valid = valid && select == 1'b0;
assign s1_valid = valid && select == 1'b1;

always_ff@(posedge clock or posedge reset) begin
  if (reset) begin
    valid <= 1'b0;
    select <= 1'b0;
  end else begin
    if (m_valid && m_ready) begin
      buffer <= m_data;
      valid <= 1'b1;
    end else if (valid) begin
      if (s0_ready && s0_valid) begin
        buffer <= 0;
        valid <= 1'b0;
      end else if (s1_ready && s1_valid) begin
        buffer <= 0;
        valid <= 1'b0;
      end
    end else begin
      valid <= 1'b0;
    end
    select <= !select;
  end
end

endmodule