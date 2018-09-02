module popcount(
  input wire [63:0] x,
  output wire [5:0] o
);

wire [4:0] tmp0, tmp1, tmp2, tmp3, tmp4, tmp5, tmp6, tmp7;

popcount_8bit popc0(
  .x(x[ 7: 0]),
  .o(tmp0)
);
popcount_8bit popc1(
  .x(x[15: 8]),
  .o(tmp1)
);
popcount_8bit popc2(
  .x(x[23:16]),
  .o(tmp2)
);
popcount_8bit popc3(
  .x(x[31:24]),
  .o(tmp3)
);
popcount_8bit popc4(
  .x(x[39:32]),
  .o(tmp4)
);
popcount_8bit popc5(
  .x(x[47:40]),
  .o(tmp5)
);
popcount_8bit popc6(
  .x(x[55:48]),
  .o(tmp6)
);
popcount_8bit popc7(
  .x(x[63:56]),
  .o(tmp7)
);

assign o = ((tmp0 + tmp1) + (tmp2 + tmp3)) + ((tmp4 + tmp5) + (tmp6 + tmp7));

//wire [15:0] x1, y1, z1, w1;
//wire [15:0] x2, y2, z2, w2;
//wire [15:0] x3, y3, z3, w3;
//
//assign x1 = (x[63:48] & 16'h5555) + ((x[63:48]  & 16'hAAAA) >>  1);
//assign y1 = (x[47:32] & 16'h5555) + ((x[47:32]  & 16'hAAAA) >>  1);
//assign z1 = (x[31:16] & 16'h5555) + ((x[31:16]  & 16'hAAAA) >>  1);
//assign w1 = (x[15: 0] & 16'h5555) + ((x[15: 0]  & 16'hAAAA) >>  1);
//assign x2 = (x1 & 16'h3333) + ((x1 & 16'hCCCC) >>  2);
//assign y2 = (y1 & 16'h3333) + ((y1 & 16'hCCCC) >>  2);
//assign z2 = (z1 & 16'h3333) + ((z1 & 16'hCCCC) >>  2);
//assign w2 = (w1 & 16'h3333) + ((w1 & 16'hCCCC) >>  2);
//assign x3 = (x2 & 16'h0F0F) + ((x2 & 16'hF0F0) >>  4);
//assign y3 = (y2 & 16'h0F0F) + ((y2 & 16'hF0F0) >>  4);
//assign z3 = (z2 & 16'h0F0F) + ((z2 & 16'hF0F0) >>  4);
//assign w3 = (w2 & 16'h0F0F) + ((w2 & 16'hF0F0) >>  4);
//assign o  = x3[15:8] + x3[7:0] + y3[15:8] + y3[7:0] + z3[15:8] + z3[7:0] + w3[15:8] + w3[7:0];

endmodule
