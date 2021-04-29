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

localparam PIPELINE_DEPTH = 9;
localparam MEMSIZE = 256;

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

// Stack
logic [153:0] stack [0:MEMSIZE-1];

// PREV-WRITE2 to FETCH
logic [63:0] x0;
logic [63:0] y0;
logic signed [7:0] result0;
logic signed [7:0] alpha0;
logic signed [7:0] beta0;
logic [3:0] stack_index0;
logic [3:0] stack_id0 = 0;
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
logic [3:0] stack_id1 = 1;
logic signed [7:0] score1;
logic [2:0] mode1;

always @(posedge iCLOCK) begin
  if (enable) begin
    if (is_moved) begin
      stack[{stack_id0, stack_index0}] <= {x0, y0, result0, alpha0, beta0, 1'b1, 1'b0};
      x1 <= x0;
      y1 <= y0;
      result1 <= result0;
      alpha1 <= alpha0;
      beta1 <= beta0;
      pass1 <= 1'b1;
      prev_passed1 <= 1'b0;
    end else begin
      {x1, y1, result1, alpha1, beta1, pass1, prev_passed1} <= stack[{stack_id0, stack_index0}];
    end
    stack_index1 <= stack_index0;
    stack_id1 <= stack_id0;
    if (is_commit) begin
      score1 <= score0;
    end else begin
      score1 <= -64;
    end
    mode1 <= mode0;
  end else begin
    stack_index1 <= 0;
    mode1 <= M_START;
  end
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
logic [3:0] stack_id2 = 2;
logic [63:0] player2;
logic [63:0] opponent2;
logic [63:0] remain2;
logic [63:0] posbit2;
logic [2:0] mode2;

always @(posedge iCLOCK) begin
  if (enable) begin
    player2 <= x1 & ~y1;
    opponent2 <= ~x1 & y1;
    remain2 <= x1 & y1;
    posbit2 <= (x1 & y1) & -(x1 & y1);
    x2 <= x1;
    y2 <= y1;
    result2 <= max(result1, score1);
    alpha2 <= max(alpha1, score1);
    beta2 <= beta1;
    pass2 <= pass1;
    prev_passed2 <= prev_passed1;
    stack_index2 <= stack_index1;
    mode2 <= mode1;
    stack_id2 <= stack_id1;
  end else begin
    stack_index2 <= 0;
    mode2 <= M_START;
  end
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
logic [3:0] stack_id3 = 3;
logic [63:0] player3;
logic [63:0] opponent3;
logic [63:0] remain3;
logic [63:0] posbit3;
logic [6:0] pos3_w;
logic [6:0] pos3;
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
  if (enable) begin
    if (mode2 != M_START) begin
      pcnt3 <= pcnt_w;
      ocnt3 <= ocnt_w;
      pos3 <= pos3_w;
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
      x3 <= x2;
      y3 <= y2;
      result3 <= result2;
      alpha3 <= alpha2;
      beta3 <= beta2;
      pass3 <= pass2;
      prev_passed3 <= prev_passed2;
      stack_index3 <= stack_index2;
      player3 <= player2;
      opponent3 <= opponent2;
      remain3 <= remain2;
      posbit3 <= posbit2;
    end else begin
      mode3 <= mode2;
    end
    stack_id3 <= stack_id2;
  end else begin
    stack_index3 <= 0;
    mode3 <= M_START;
  end
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
logic [3:0] stack_id4 = 4;
logic [63:0] player4;
logic [63:0] opponent4;
logic [63:0] remain4;
logic [63:0] posbit4;
logic [6:0] pos4;
logic [6:0] pcnt4;
logic [6:0] ocnt4;
logic [2:0] mode4;
logic signed [7:0] score4;

logic [63:0] oflip;

flip_v2 flip(
  .clock(iCLOCK),
  .player(player3),
  .opponent(opponent3),
  .pos(pos3),
  .flip(oflip)
);

always @(posedge iCLOCK) begin
  if (enable) begin
    if (pcnt3 > ocnt3) begin
      score4 <= 64 - (ocnt3 << 1);
    end else if (pcnt3 < ocnt3) begin
      score4 <= -64 + (pcnt3 << 1);
    end else begin
      score4 <= 0;
    end
    case (mode3)
      M_COMMIT:;
      M_SAVE:;
      M_PASS:;
      M_NORMAL:;
    endcase
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
    remain4 <= remain3;
    posbit4 <= posbit3;
    pos4 <= pos3;
    pcnt4 <= pcnt3;
    ocnt4 <= ocnt3;
    mode4 <= mode3;
  end else begin
    stack_index4 <= 0;
    mode4 <= M_START;
  end
end

// EXEC2 to EXEC3
logic [63:0] x5;
logic [63:0] y5;
logic signed [7:0] result5;
logic signed [7:0] alpha5;
logic signed [7:0] beta5;
logic pass5;
logic prev_passed5;
logic [3:0] stack_index5;
logic [3:0] stack_id5 = 5;
logic [63:0] player5;
logic [63:0] opponent5;
logic [63:0] remain5;
logic [63:0] posbit5;
logic [6:0] pos5;
logic [6:0] pcnt5;
logic [6:0] ocnt5;
logic [2:0] mode5;
logic signed [7:0] score5;

always @(posedge iCLOCK) begin
  if (enable) begin
    case (mode4)
      M_COMMIT:;
      M_SAVE:;
      M_PASS:;
      M_NORMAL:;
    endcase
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
    remain5 <= remain4;
    posbit5 <= posbit4;
    pos5 <= pos4;
    pcnt5 <= pcnt4;
    ocnt5 <= ocnt4;
    mode5 <= mode4;
    score5 <= score4;
  end else begin
    stack_index5 <= 0;
    mode5 <= M_START;
  end
end

// EXEC3 to EXEC4
logic [63:0] x6;
logic [63:0] y6;
logic signed [7:0] result6;
logic signed [7:0] alpha6;
logic signed [7:0] beta6;
logic pass6;
logic prev_passed6;
logic [3:0] stack_index6;
logic [3:0] stack_id6 = 6;
logic [63:0] player6;
logic [63:0] opponent6;
logic [63:0] remain6;
logic [63:0] posbit6;
logic [6:0] pos6;
logic [6:0] pcnt6;
logic [6:0] ocnt6;
logic [2:0] mode6;
logic signed [7:0] score6;

always @(posedge iCLOCK) begin
  if (enable) begin
    case (mode5)
      M_COMMIT:;
      M_SAVE:;
      M_PASS:;
      M_NORMAL:;
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
    remain6 <= remain5;
    posbit6 <= posbit5;
    pos6 <= pos5;
    pcnt6 <= pcnt5;
    ocnt6 <= ocnt5;
    mode6 <= mode5;
    score6 <= score5;
  end else begin
    stack_index6 <= 0;
    mode6 <= M_START;
  end
end

// EXEC4 to WRITE1
logic [63:0] x7;
logic [63:0] y7;
logic signed [7:0] result7;
logic signed [7:0] alpha7;
logic signed [7:0] beta7;
logic pass7;
logic prev_passed7;
logic [3:0] stack_index7;
logic [3:0] stack_id7 = 7;
logic [63:0] player7;
logic [63:0] opponent7;
logic [63:0] remain7;
logic [63:0] posbit7;
logic [6:0] pos7;
logic [6:0] pcnt7;
logic [6:0] ocnt7;
logic [2:0] mode7;
logic signed [7:0] score7;

always @(posedge iCLOCK) begin
  if (enable) begin
    x7 <= x6;
    y7 <= y6;
    result7 <= result6;
    alpha7 <= alpha6;
    beta7 <= beta6;
    pass7 <= pass6;
    prev_passed7 <= prev_passed6;
    stack_index7 <= stack_index6;
    stack_id7 <= stack_id6;
    player7 <= player6;
    opponent7 <= opponent6;
    remain7 <= remain6;
    posbit7 <= posbit6;
    pos7 <= pos6;
    pcnt7 <= pcnt6;
    ocnt7 <= ocnt6;
    mode7 <= mode6;
    score7 <= score6;
  end else begin
    stack_index7 <= 0;
    mode7 <= M_START;
  end
end

// WRITE1 to WRITE2
logic [63:0] x8;
logic [63:0] y8;
logic signed [7:0] result8;
logic signed [7:0] alpha8;
logic signed [7:0] beta8;
logic pass8;
logic prev_passed8;
logic [3:0] stack_index8;
logic [3:0] stack_id8 = 8;
logic [63:0] player8;
logic [63:0] opponent8;
logic [63:0] remain8;
logic [63:0] posbit8;
logic [6:0] pos8;
logic [6:0] pcnt8;
logic [6:0] ocnt8;
logic [2:0] mode8;
logic signed [7:0] score8;
logic [63:0] next_me8;
logic [63:0] next_op8;
logic move8;

always @(posedge iCLOCK) begin
  if (enable) begin
    //$display("At7: %h %h %h %d %d", player7, opponent7, oflip, pos7, mode7);
    case (mode7)
      M_NORMAL: begin
        if (|oflip) begin
          next_me8 <= opponent7 ^ oflip;
          next_op8 <= (player7 ^ oflip) | posbit7;
          move8 <= 1'b1;
        end else begin
          move8 <= 1'b0;
        end
      end
      default: begin
        move8 <= 1'b0;
      end
    endcase
    x8 <= x7;
    y8 <= y7;
    result8 <= result7;
    alpha8 <= alpha7;
    beta8 <= beta7;
    pass8 <= pass7;
    prev_passed8 <= prev_passed7;
    stack_index8 <= stack_index7;
    stack_id8 <= stack_id7;
    player8 <= player7;
    opponent8 <= opponent7;
    remain8 <= remain7;
    posbit8 <= posbit7;
    pos8 <= pos7;
    pcnt8 <= pcnt7;
    ocnt8 <= ocnt7;
    mode8 <= mode7;
    score8 <= score7;
  end else begin
    stack_index8 <= 0;
    mode8 <= M_START;
  end
end

always @(posedge iCLOCK) begin
  if (enable) begin
    case (mode8)
      M_NORMAL: begin
        if (move8) begin
          stack[{stack_id8, stack_index8}] <= {x8 ^ posbit8, y8 ^ posbit8, result8, alpha8, beta8, 1'b0, prev_passed8};
          x0 <= ~next_op8;
          y0 <= ~next_me8;
          result0 <= -8'd64;
          alpha0 <= -beta8;
          beta0 <= -alpha8;
          stack_index0 <= stack_index8 + 1;
        end else begin
          stack[{stack_id8, stack_index8}] <= {x8 ^ posbit8, y8 ^ posbit8, result8, alpha8, beta8, pass8, prev_passed8};
          stack_index0 <= stack_index8;
        end
        solved <= 1'b0;
        is_commit <= 1'b0;
        is_moved <= move8;
      end
      M_SAVE: begin
        score0 <= score8;
        if (stack_index8) begin
          is_commit <= 1'b1;
          stack_index0 <= stack_index8 - 1;
          is_moved <= 1'b0;
          solved <= 1'b0;
        end else begin
          is_commit <= 1'b0;
          solved <= 1'b1;
          oPlayer <= player8;
          oOpponent <= opponent8;
          res <= -score8;
          stack_index0 <= 0;
          is_moved <= 1'b1;
          x0 <= ~iOpponent;
          y0 <= ~iPlayer;
          result0 <= -8'd64;
          alpha0 <= -8'd64;
          beta0 <= 8'd64;
        end
      end
      M_COMMIT: begin
        score0 <= prev_passed8 ? result8 : -result8;
        if (stack_index8) begin
          is_commit <= 1'b1;
          stack_index0 <= stack_index8 - 1;
          is_moved <= 1'b0;
          solved <= 1'b0;
        end else begin
          is_commit <= 1'b0;
          solved <= 1'b1;
          oPlayer <= player8;
          oOpponent <= opponent8;
          res <= prev_passed8 ? -result8 : result8;
          stack_index0 <= 0;
          is_moved <= 1'b1;
          x0 <= ~iOpponent;
          y0 <= ~iPlayer;
          result0 <= -8'd64;
          alpha0 <= -8'd64;
          beta0 <= 8'd64;
        end
      end
      M_PASS: begin
        is_commit <= 1'b0;
        stack[{stack_id8, stack_index8}] <= {~player8, ~opponent8, -8'd64, -beta8, -alpha8, 1'b1, 1'b1};
        stack_index0 <= stack_index8;
        is_moved <= move8;
        solved <= 1'b0;
      end
      M_START: begin
        is_commit <= 1'b0;
        stack_index0 <= 0;
        is_moved <= 1'b1;
        x0 <= ~iOpponent;
        y0 <= ~iPlayer;
        result0 <= -8'd64;
        alpha0 <= -8'd64;
        beta0 <= 8'd64;
        mode0 <= M_NORMAL;
      end
    endcase
    stack_id0 <= stack_id8;
  end else begin
    stack_index0 <= 0;
    mode0 <= M_START;
  end
end

endmodule
