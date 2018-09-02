module popcount_8bit(
  input wire [7:0] x,
  output wire [4:0] o
);
wire [1:0] a, b, c, d;
assign a = x[0] + x[1];
assign b = x[2] + x[3];
assign c = x[4] + x[5];
assign d = x[6] + x[7];

wire [1:0] p, q, r, s;
assign p = a[0] + b[0];
assign q = a[1] + b[1];
assign r = c[0] + d[0];
assign s = c[1] + d[1];

assign o = {q[1], q[0] | p[1], p[0]} + {s[1], s[0] | r[1], r[0]};

endmodule
