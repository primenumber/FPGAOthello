module branch_feeder#(
  parameter LEVEL = 3
)
(
    input clock,
    input reset,
    input wire [143:0] input_data,
    input wire input_valid,
    output wire input_ready,
    output wire [39:0] output_data,
    output wire output_valid,
    input wire output_ready
    );

generate
  if (LEVEL == 0) begin
    feed core(
      .clock(clock),
      .reset(reset),
      .input_data(input_data),
      .input_valid(input_valid),
      .input_ready(input_ready),
      .output_data(output_data),
      .output_valid(output_valid),
      .output_ready(output_ready)
    );
  end else begin
    logic [143:0] input_data0;
    logic [143:0] input_data1;
    logic input_valid0;
    logic input_valid1;
    logic input_ready0;
    logic input_ready1;
    logic [39:0] output_data0;
    logic [39:0] output_data1;
    logic output_valid0;
    logic output_valid1;
    logic output_ready0;
    logic output_ready1;
    logic [39:0] output_data_buf;
    logic output_valid_buf;


    branch_feeder#(.LEVEL(LEVEL-1)) feeder0(
      .clock(clock),
      .reset(reset),
      .input_data(input_data0),
      .input_valid(input_valid0),
      .input_ready(input_ready0),
      .output_data(output_data0),
      .output_valid(output_valid0),
      .output_ready(output_ready0)
    );

    branch_feeder#(.LEVEL(LEVEL-1)) feeder1(
      .clock(clock),
      .reset(reset),
      .input_data(input_data1),
      .input_valid(input_valid1),
      .input_ready(input_ready1),
      .output_data(output_data1),
      .output_valid(output_valid1),
      .output_ready(output_ready1)
    );

    broadcast #(.width(144)) broadcast(
      .clock(clock),
      .reset(reset),
      .m_data(input_data),
      .m_valid(input_valid),
      .m_ready(input_ready),
      .s0_data(input_data0),
      .s0_valid(input_valid0),
      .s0_ready(input_ready0),
      .s1_data(input_data1),
      .s1_valid(input_valid1),
      .s1_ready(input_ready1)
    );

    gather #(.width(40)) gather(
      .clock(clock),
      .reset(reset),
      .m0_data(output_data0),
      .m0_valid(output_valid0),
      .m0_ready(output_ready0),
      .m1_data(output_data1),
      .m1_valid(output_valid1),
      .m1_ready(output_ready1),
      .s_data(output_data),
      .s_valid(output_valid),
      .s_ready(output_ready)
    );
  end
endgenerate

endmodule