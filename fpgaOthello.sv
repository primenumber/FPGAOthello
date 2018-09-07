`default_nettype none

module fpgaOthello(
  input wire CLOCK_50,
  input wire RESET_N,
  output wire [4:0] LEDR
);

wire res_n;
reg por_n; // should be power-up level = Low
reg [23:0] por_count; // should be power-up level = Low
wire signed [7:0] res;
reg enable;
reg [63:0] iPlayer;
reg [63:0] iOpponent;
wire solved;

processer PROC(
  .*,
  .iCLOCK(CLOCK_50),
  .o(LEDR[4:0])
);

wire [31:0] out;
reg [31:0] in;

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

nios_uart UART(
  .clk_clk(CLOCK_50),
  .out_port_from_pio_0_export(out),
  .in_port_from_pio_1_export(in),
  .reset_reset_n(res_n)
);

always@(posedge CLOCK_50) begin
  if (out[19] == 0) begin
    enable <= 0;
    case(out[18:16])
      3'd0: begin
        iPlayer[15:0] <= out[15:0];
      end
      3'd1: begin
        iPlayer[31:16] <= out[15:0];
      end
      3'd2: begin
        iPlayer[47:32] <= out[15:0];
      end
      3'd3: begin
        iPlayer[63:48] <= out[15:0];
      end
      3'd4: begin
        iOpponent[15:0] <= out[15:0];
      end
      3'd5: begin
        iOpponent[31:16] <= out[15:0];
      end
      3'd6: begin
        iOpponent[47:32] <= out[15:0];
      end
      3'd7: begin
        iOpponent[63:48] <= out[15:0];
      end
    endcase
    in <= 0;
  end else begin
    enable <= 1;
    if (solved) begin
      in <= {15'd0, 1'b1, 8'd0, res};
    end
  end
end

assign res_n = por_n;

initial begin
  in <= 0;
  enable <= 0;
end

endmodule
