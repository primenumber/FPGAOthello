module processer(
  input wire iCLOCK,
  input wire enable,
  input wire [63:0] iPlayer,
  input wire [63:0] iOpponent,
  output reg solved,
  output reg signed [7:0] res,
  output reg [4:0] o
);

reg [3:0] stack_index;
wire [63:0] oFlip;
reg [63:0] player;
reg [63:0] opponent;
reg [5:0] pos;
reg [7:0] prob_index;
reg signed [7:0] result;
reg signed [7:0] old_result;
reg [4:0] state;
reg [2:0] mode;

//reg [3:0] stack_index;

(* RAM_STYLE="BLOCK" *) reg [153:0] stack_ [0:15];
(* RAM_STYLE="BLOCK" *) reg [7:0] answer [0:127];

reg wren;
reg [255:0] q;
reg [255:0] data;

//stack STK(
//  .*,
//  .clock(iCLOCK),
//  .rdaddress(stack_index),
//  .wraddress(stack_index)
//);

function signed [7:0] max;
  input signed [7:0] x;
  input signed [7:0] y;
  begin
    max = x >= y ? x : y;
  end
endfunction

reg [143:0] prob;
reg [63:0] x;
reg [63:0] y;
//reg [63:0] player;
//reg [63:0] opponent;
reg [63:0] remain;
reg signed [7:0] alpha;
reg signed [7:0] beta;
reg pass;
reg prev_passed;

reg [63:0] pos_bit;
//reg [5:0] pos;
wire [5:0] opos;
reg signed [7:0] new_result;
reg signed [7:0] new_alpha;
reg signed [7:0] old_result_neg;

//wire [63:0] oFlip;

flip FLIP(
  .*,
  .iPlayer(player),
  .iOpponent(opponent),
  .iPos(pos)
);

popcount PCNT(
  .x(pos_bit - 1),
  .o(opos)
);

wire [7:0] oScore;

score SCORE(
  .iPlayer(player),
  .iOpponent(opponent),
  .o(oScore)
);

parameter S_START0        = 5'h00,
          S_START1        = 5'h01,
          S_READ0         = 5'h02,
          S_READ1         = 5'h03,
          S_CHECK         = 5'h04,
          S_WAIT0         = 5'h05,
          S_WAIT1         = 5'h06,
          S_WAIT2         = 5'h07,
          S_WAIT3         = 5'h08,
          S_WAIT4         = 5'h09,
          S_WRITE0        = 5'h0A,
          S_WRITE1        = 5'h0B;

parameter M_NORMAL = 3'h0,
          M_COMMIT = 3'h1,
          M_SAVE   = 3'h2,
          M_PASS   = 3'h3,
          M_NEXT   = 3'h4,
          M_NOMOVE = 3'h5,
          M_HALT   = 3'h6;

always@(posedge iCLOCK) begin
  if (enable) begin
    case (state)
      S_START0: begin
        if (prob_index) begin
          res <= prev_passed ? -old_result : old_result;
          answer[prob_index-1] <= prev_passed ? -old_result : old_result;
          solved <= 1'b1;
        end
        if (prob_index != 8'hFF) begin
          stack_index <= 0;
          stack_[stack_index] <= {~iOpponent, ~iPlayer, -8'd64, -8'd64, 8'd64, 1'b1, 1'b0};
          prob_index <= prob_index + 8'd1;
          mode <= M_NORMAL;
        end else begin
          //state = S_HALT;
          mode <= M_HALT;
        end
        state = S_START1;
      end
      S_START1: begin
        solved <= 1'b0;
        state = S_READ0;
      end
      S_READ0:begin
        if (mode != M_HALT) begin
          {x, y, result, alpha, beta, pass, prev_passed} <= stack_[stack_index];
        end
        state = S_READ1;
      end
      S_READ1:begin
        if (mode != M_HALT) begin
          player = x & ~y;
          opponent = ~x & y;
          remain = x & y;
        end
        state = S_CHECK;
      end
      S_CHECK:begin
        if (mode != M_HALT) begin
          if (remain == 64'd0) begin
            if (pass) begin
              if (prev_passed) begin
                //state = S_SAVE_SCORE;
                mode <= M_SAVE;
              end else begin
                //state = S_PASS;
                mode <= M_PASS;
              end
            end else begin
              old_result <= prev_passed ? -result : result;
              if (stack_index) begin
                stack_index <= stack_index - 4'd1;
                //state = S_COMMIT_READ0;
                mode <= M_COMMIT;
              end else begin
                //state = S_START0;
                mode <= M_NEXT;
              end
            end
          end else if (alpha >= beta) begin
            old_result <= prev_passed ? -result : result;
            if (stack_index) begin
              stack_index <= stack_index - 4'd1;
              //state = S_COMMIT_READ0;
              mode <= M_COMMIT;
            end else begin
              //state = S_START0;
              mode <= M_NEXT;
            end
          end else begin
            pos_bit <= remain & -remain;
            mode <= M_NORMAL;
          end
        end
        state = S_WAIT0;
      end
      S_WAIT0: begin
        case (mode)
          M_NORMAL: begin
            stack_[stack_index] <= {x ^ pos_bit, y ^ pos_bit, result, alpha, beta, pass, prev_passed};
          end
          M_SAVE: begin
            old_result <= prev_passed ? -oScore : oScore;
            if (stack_index) begin
              stack_index <= stack_index - 4'd1;
              //state = S_COMMIT_READ0;
              mode <= M_COMMIT;
            end else begin
              //state = S_START0;
              mode <= M_NEXT;
            end
          end
          M_PASS: begin
            stack_[stack_index] <= {~player, ~opponent, -8'd64, -beta, -alpha, 1'b1, 1'b1};
            //state = S_START1;
          end
        endcase
        state = S_WAIT1;
      end
      S_WAIT1: begin
        case (mode)
          M_COMMIT: begin
            {x, y, result, alpha, beta, pass, prev_passed} <= stack_[stack_index];
            old_result_neg <= -old_result;
            //state = S_COMMIT_READ1;
          end
          M_NEXT: begin
            if (prob_index) begin
              res <= prev_passed ? -old_result : old_result;
              answer[prob_index-1] <= prev_passed ? -old_result : old_result;
              solved <= 1'b1;
            end
            if (prob_index != 8'hFF) begin
              stack_index <= 0;
              stack_[stack_index] <= {~iOpponent, ~iPlayer, -8'd64, -8'd64, 8'd64, 1'b1, 1'b0};
              prob_index <= prob_index + 8'd1;
              //state = S_START1;
              mode <= M_NOMOVE;
            end else begin
              //state = S_HALT;
              mode <= M_HALT;
            end
          end
        endcase
        state = S_WAIT2;
      end
      S_WAIT2: begin
        if (mode == M_COMMIT) begin
          new_result <= max(result, old_result_neg);
          new_alpha <= max(alpha, old_result_neg);
          //state = S_COMMIT_WRITE;
        end
        state = S_WAIT3;
      end
      S_WAIT3: begin
        if (mode == M_COMMIT) begin
          stack_[stack_index] <= {x, y, new_result, new_alpha, beta, pass, prev_passed};
          //state = S_START1;
        end
        state = S_WAIT4;
      end
      S_WAIT4: begin
        state = S_WRITE0;
      end
      S_WRITE0: begin
        if (mode == M_NORMAL) begin
          if (|oFlip != 0) begin
            stack_[stack_index] <= {x ^ pos_bit, y ^ pos_bit, result, alpha, beta, 1'b0, prev_passed};
            stack_index <= stack_index + 4'd1;
            mode <= M_NORMAL;
          end else begin
            //state = S_START1;
            mode <= M_NOMOVE;
          end
        end
        state = S_WRITE1;
      end
      S_WRITE1: begin
        if (mode == M_NORMAL) begin
          stack_[stack_index] <= {~((player ^ oFlip) | pos_bit), ~(opponent ^ oFlip), -8'd64, -beta, -alpha, 1'b1, 1'b0};
        end
        state = S_START1;
        if (mode != M_HALT) begin
          mode <= M_NORMAL;
        end
      end
    endcase
    o <= state;
  end else begin
    prob_index <= 0;
    o <= 3'b000;
    state = S_START0;
  end
  pos <= opos;
end

integer i;
initial begin
  state <= S_START1;
  stack_index <= 0;
  prob_index <= 0;
  mode <= 0;
end

endmodule
