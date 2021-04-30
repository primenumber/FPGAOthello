module pipeline(
  input wire iCLOCK,
  input wire enable,
  input wire [63:0] iPlayer,
  input wire [63:0] iOpponent,
  output reg solved,
  output reg [63:0] oPlayer,
  output reg [63:0] oOpponent,
  output reg signed [7:0] res,
  output reg [4:0] o
);

localparam MEMSIZE = 128;

localparam M_NORMAL = 3'h0,
           M_COMMIT = 3'h1,
           M_SAVE   = 3'h2,
           M_PASS   = 3'h3,
           M_START  = 3'h4;

function signed [7:0] max;
  input signed [7:0] x;
  input signed [7:0] y;
  begin
    max = x >= y ? x : y;
  end
endfunction

// PREV-WRITE2 to FETCH
logic [63:0] x0;
logic [63:0] y0;
logic signed [7:0] alpha0;
logic signed [7:0] beta0;
logic [3:0] stack_index0;
logic [2:0] stack_id0 = 0;
logic is_moved;
logic is_commit;
logic signed [7:0] score0;
logic [2:0] mode0;

// FETCH to DECODE1
logic [63:0] x1;
logic [63:0] y1;
logic signed [7:0] result1;
logic signed [7:0] alpha1;
logic signed [7:0] beta1;
logic pass1;
logic prev_passed1;
logic [3:0] stack_index1;
logic [2:0] stack_id1 = 1;
logic signed [7:0] score1;
logic [2:0] mode1;

wire [6:0] raddr = {stack_index0, stack_id0};
wire [153:0] rdata;

always @(posedge iCLOCK) begin
  if (is_moved) begin
    x1 <= x0;
    y1 <= y0;
    result1 <= -8'd64;
    alpha1 <= alpha0;
    beta1 <= beta0;
    pass1 <= 1'b1;
    prev_passed1 <= 1'b0;
  end else begin
    {x1, y1, result1, alpha1, beta1, pass1, prev_passed1} <= rdata;
  end
  if (is_commit) begin
    score1 <= score0;
  end else begin
    score1 <= -64;
  end
  stack_index1 <= stack_index0;
  stack_id1 <= stack_id0;
  mode1 <= mode0;
  o <= stack_id0;
end

// DECODE1 to DECODE2
logic [63:0] x2;
logic [63:0] y2;
logic signed [7:0] result2;
logic signed [7:0] alpha2;
logic signed [7:0] beta2;
logic pass2;
logic prev_passed2;
logic [3:0] stack_index2;
logic [2:0] stack_id2 = 2;
logic [63:0] player2;
logic [63:0] opponent2;
logic [63:0] remain2;
logic [63:0] posbit2;
logic [2:0] mode2;

always @(posedge iCLOCK) begin
  x2 <= x1;
  y2 <= y1;
  result2 <= max(result1, score1);
  alpha2 <= max(alpha1, score1);
  beta2 <= beta1;
  pass2 <= pass1;
  prev_passed2 <= prev_passed1;
  stack_index2 <= stack_index1;
  stack_id2 <= stack_id1;
  player2 <= x1 & ~y1;
  opponent2 <= ~x1 & y1;
  remain2 <= x1 & y1;
  posbit2 <= (x1 & y1) & -(x1 & y1);
  mode2 <= mode1;
end

// DECODE2 to EXEC1
logic [63:0] x3;
logic [63:0] y3;
logic signed [7:0] result3;
logic signed [7:0] alpha3;
logic signed [7:0] beta3;
logic pass3;
logic prev_passed3;
logic [3:0] stack_index3;
logic [2:0] stack_id3 = 3;
logic [63:0] player3;
logic [63:0] opponent3;
logic [63:0] posbit3;
logic [6:0] pos3_w;
logic [5:0] pos3;
logic [6:0] pcnt_w;
logic [6:0] ocnt_w;
logic [6:0] pcnt3;
logic [6:0] ocnt3;
logic [2:0] mode3;

popcount popcnt1(
  .x(player2),
  .o(pcnt_w)
);

popcount popcnt2(
  .x(opponent2),
  .o(ocnt_w)
);

popcount popcnt3(
  .x(posbit2 - 1),
  .o(pos3_w)
);

always @(posedge iCLOCK) begin
  if (mode2 != M_START) begin
    if (|remain2 == 1'b0) begin
      if (pass2) begin
        if (prev_passed2) begin
          mode3 <= M_SAVE;
        end else begin
          mode3 <= M_PASS;
        end
      end else begin
        mode3 <= M_COMMIT;
      end
    end else if (alpha2 >= beta2) begin
      mode3 <= M_COMMIT;
    end else begin
      mode3 <= M_NORMAL;
    end
  end else begin
    mode3 <= mode2;
  end
  x3 <= x2;
  y3 <= y2;
  result3 <= result2;
  alpha3 <= alpha2;
  beta3 <= beta2;
  pass3 <= pass2;
  prev_passed3 <= prev_passed2;
  stack_index3 <= stack_index2;
  stack_id3 <= stack_id2;
  player3 <= player2;
  opponent3 <= opponent2;
  posbit3 <= posbit2;
  pos3 <= pos3_w[5:0];
  pcnt3 <= pcnt_w;
  ocnt3 <= ocnt_w;
end

// EXEC1 to EXEC2
logic [63:0] x4;
logic [63:0] y4;
logic signed [7:0] result4;
logic signed [7:0] alpha4;
logic signed [7:0] beta4;
logic pass4;
logic prev_passed4;
logic [3:0] stack_index4;
logic [2:0] stack_id4 = 4;
logic [63:0] player4;
logic [63:0] opponent4;
logic [63:0] posbit4;
logic [6:0] pcnt4;
logic [6:0] ocnt4;
logic [2:0] mode4;
logic signed [7:0] score4;

logic [63:0] oflip5;

flip_v2 flip(
  .clock(iCLOCK),
  .player(player3),
  .opponent(opponent3),
  .pos(pos3),
  .flip(oflip5)
);

always @(posedge iCLOCK) begin
  if (pcnt3 > ocnt3) begin
    score4 <= 64 - (ocnt3 << 1);
  end else if (pcnt3 < ocnt3) begin
    score4 <= -64 + (pcnt3 << 1);
  end else begin
    score4 <= 0;
  end
  x4 <= x3;
  y4 <= y3;
  result4 <= result3;
  alpha4 <= alpha3;
  beta4 <= beta3;
  pass4 <= pass3;
  prev_passed4 <= prev_passed3;
  stack_index4 <= stack_index3;
  stack_id4 <= stack_id3;
  player4 <= player3;
  opponent4 <= opponent3;
  posbit4 <= posbit3;
  pcnt4 <= pcnt3;
  ocnt4 <= ocnt3;
  mode4 <= mode3;
end

// EXEC2 to WRITE1
logic [63:0] x5;
logic [63:0] y5;
logic signed [7:0] result5;
logic signed [7:0] alpha5;
logic signed [7:0] beta5;
logic pass5;
logic prev_passed5;
logic [3:0] stack_index5;
logic [2:0] stack_id5 = 5;
logic [63:0] player5;
logic [63:0] opponent5;
logic [63:0] posbit5;
logic [6:0] pcnt5;
logic [6:0] ocnt5;
logic [2:0] mode5;
logic signed [7:0] score5;

always @(posedge iCLOCK) begin
  x5 <= x4;
  y5 <= y4;
  result5 <= result4;
  alpha5 <= alpha4;
  beta5 <= beta4;
  pass5 <= pass4;
  prev_passed5 <= prev_passed4;
  stack_index5 <= stack_index4;
  stack_id5 <= stack_id4;
  player5 <= player4;
  opponent5 <= opponent4;
  posbit5 <= posbit4;
  pcnt5 <= pcnt4;
  ocnt5 <= ocnt4;
  mode5 <= mode4;
  score5 <= score4;
end

// WRITE1 to WRITE2
logic [63:0] x6;
logic [63:0] y6;
logic signed [7:0] result6;
logic signed [7:0] alpha6;
logic signed [7:0] beta6;
logic pass6;
logic prev_passed6;
logic [3:0] stack_index6;
logic [2:0] stack_id6 = 6;
logic [63:0] player6;
logic [63:0] opponent6;
logic [63:0] posbit6;
logic [6:0] pcnt6;
logic [6:0] ocnt6;
logic [2:0] mode6;
logic signed [7:0] score6;
logic [63:0] oflip6;
logic move6;

always @(posedge iCLOCK) begin
  case (mode5)
    M_NORMAL: begin
      if (|oflip5) begin
        move6 <= 1'b1;
      end else begin
        move6 <= 1'b0;
      end
    end
    default: begin
      move6 <= 1'b0;
    end
  endcase
  x6 <= x5;
  y6 <= y5;
  result6 <= result5;
  alpha6 <= alpha5;
  beta6 <= beta5;
  pass6 <= pass5;
  prev_passed6 <= prev_passed5;
  stack_index6 <= stack_index5;
  stack_id6 <= stack_id5;
  player6 <= player5;
  opponent6 <= opponent5;
  posbit6 <= posbit5;
  pcnt6 <= pcnt5;
  ocnt6 <= ocnt5;
  mode6 <= mode5;
  score6 <= score5;
  oflip6 <= oflip5;
end

wire [6:0] waddr = {stack_index6, stack_id6};
wire [63:0] wx = mode6 == M_PASS ? ~player6 : (x6 ^ posbit6);
wire [63:0] wy = mode6 == M_PASS ? ~opponent6 : (y6 ^ posbit6);
wire signed [7:0] wresult = mode6 == M_PASS ? -8'd64 : result6;
wire signed [7:0] walpha = mode6 == M_PASS ? -beta6 : alpha6;
wire signed [7:0] wbeta = mode6 == M_PASS ? -alpha6 : beta6;
wire wpass = mode6 == M_PASS ? 1'b1 : (move6 ? 1'b0 : pass6);
wire wprev_passed = mode6 == M_PASS ? 1'b1 : prev_passed6;
wire we = mode6 == M_NORMAL | mode6 == M_PASS;
wire [153:0] wdata = {wx, wy, wresult, walpha, wbeta, wpass, wprev_passed};

always @(posedge iCLOCK) begin
  if (enable) begin
    case (mode6)
      M_NORMAL: begin
        if (move6) begin
          stack_index0 <= stack_index6 + 1;
        end else begin
          stack_index0 <= stack_index6;
        end
        solved <= 1'b0;
        is_commit <= 1'b0;
        is_moved <= move6;
      end
      M_SAVE: begin
        score0 <= score6;
        if (stack_index6) begin
          is_commit <= 1'b1;
          stack_index0 <= stack_index6 - 1;
          is_moved <= 1'b0;
          solved <= 1'b0;
        end else begin
          is_commit <= 1'b0;
          stack_index0 <= 0;
          is_moved <= 1'b1;
          solved <= 1'b1;
        end
        res <= -score6;
      end
      M_COMMIT: begin
        score0 <= prev_passed6 ? result6 : -result6;
        if (stack_index6) begin
          is_commit <= 1'b1;
          stack_index0 <= stack_index6 - 1;
          is_moved <= 1'b0;
          solved <= 1'b0;
        end else begin
          is_commit <= 1'b0;
          stack_index0 <= 0;
          is_moved <= 1'b1;
          solved <= 1'b1;
        end
        res <= prev_passed6 ? -result6 : result6;
      end
      M_PASS: begin
        is_commit <= 1'b0;
        stack_index0 <= stack_index6;
        is_moved <= 1'b0;
        solved <= 1'b0;
      end
      M_START: begin
        is_commit <= 1'b0;
        stack_index0 <= 0;
        is_moved <= 1'b1;
        solved <= 1'b0;
      end
    endcase
    mode0 <= M_NORMAL;
  end else begin
    stack_index0 <= 0;
    mode0 <= M_START;
    solved <= 1'b0;
  end
  if (move6) begin
    x0 <= ~((player6 ^ oflip6) | posbit6);
    y0 <= ~(opponent6 ^ oflip6);
    alpha0 <= -beta6;
    beta0 <= -alpha6;
  end else begin
    x0 <= ~iOpponent;
    y0 <= ~iPlayer;
    alpha0 <= -8'd64;
    beta0 <= 8'd64;
  end
  oPlayer <= player6;
  oOpponent <= opponent6;
  stack_id0 <= stack_id6;
end

// Stack
bram bram(
  .clock(iCLOCK),
  .ra(raddr),
  .rd(rdata),
  .we(we),
  .wa(waddr),
  .wd(wdata));

endmodule
