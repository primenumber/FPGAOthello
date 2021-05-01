module bram(
  input wire clock,
  input wire [5:0] ra,
  output reg [153:0] rd,
  input wire we,
  input wire [5:0] wa,
  input wire [153:0] wd
);

reg [153:0] bram[0:63];

always @(posedge clock) begin
  if (we) begin
    bram[wa] <= wd;
  end
end

always@(posedge clock) begin
  if (we && wa == ra) begin
    rd = wd;
  end else begin
    rd <= bram[ra];
  end
end

endmodule
