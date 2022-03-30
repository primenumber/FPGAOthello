module fifo 
#(parameter width = 40, addr_bits = 3)
(
  input clock,
  input reset,
  input ren,
  output reg [width-1:0] rdata,
  input wen,
  input [width-1:0] wdata,
  output reg [addr_bits:0] count
);

parameter int depth = 2 ** addr_bits;

reg [width-1:0] buffer[0:depth-1];
reg [addr_bits:0] waddr;
reg [addr_bits-1:0] raddr;

wire empty = count == 0;
wire full = count == depth;
wire raccept = ren && (wen || !empty);
wire waccept = wen && (ren || !full);

always_ff@(posedge clock or posedge reset) begin
  if (reset) begin
    count <= 0;
  end else begin
    case ({waccept, raccept})
    2'b00: count <= count;
    2'b01: count <= count - 1'b1;
    2'b10: count <= count + 1'b1;
    2'b11: count <= count;
    endcase
  end
end

always_ff@(posedge clock or posedge reset) begin
  if (reset) begin
    waddr <= 0;
  end else begin
    if (waccept) begin
      buffer[waddr[addr_bits-1:0]] <= wdata;
      if (raddr == depth - 1 && raccept) begin
        waddr <= waddr - depth + 1;
      end else begin
        waddr <= waddr + 1;
      end
    end else begin
      if (raddr == depth - 1 && raccept) begin
        waddr <= waddr - depth;
      end else begin
        waddr <= waddr;
      end
    end
  end
end

always_ff@(posedge clock or posedge reset) begin
  if (reset) begin
    raddr <= 0;
  end else begin
    if (raccept) begin
      if (count == 0) begin
        rdata <= wdata;
      end else begin
        rdata <= buffer[raddr[addr_bits-1:0]];
      end
      if (raddr == depth - 1) begin
        raddr <= 0;
      end else begin
        raddr <= raddr + 1;
      end
    end else begin
      raddr <= raddr;
      rdata <= rdata;
    end
  end
end

endmodule