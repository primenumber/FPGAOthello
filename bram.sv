module bram(
  input wire clock,
  input wire [7:0] ra,
  output wire [153:0] rd,
  input wire we,
  input wire [7:0] wa,
  input wire [153:0] wd
);

(* RAM_STYLE="BLOCK" *) reg [153:0] bram[0:255];

assign rd = bram[ra];

always @(posedge clock) begin
  if (we) begin
    bram[wa] <= wd;
  end
end

endmodule
