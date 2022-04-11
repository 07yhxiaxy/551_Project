module nonoverlap (
    input clk, rst_n, highIn, lowIn,
    output reg highOut, lowOut
);

logic hff1, hff2; // FFs used to remove glitch and detect changes in high signal
logic lff1, lff2; // FFs used to remove glitch and detect changes in low signal

logic [4:0] cnt;  // counter used to count 32 clk cycles
logic cnt_en, diff, clr_cnt;

typedef enum reg {NADA, COUNTING} state_t;

// FF that sense difference in inputs
always_ff @(posedge clk, negedge rst_n) begin
    if (~rst_n) begin
        hff1 <= 0;
        hff2 <= 0;
        lff1 <= 0;
        lff2 <= 0;
    end
    else begin
        // Detect difference
        hff1 <= highIn;
        hff2 <= hff1;

        lff1 <= lowIn;
        lff2 <= lff1;
    end
end
assign diff = (hff2 ^ hff1) | (lff2 ^ lff1);

assign lowOut = cnt_en ? 0 : lff2;
assign highOut = cnt_en ? 0 : hff2;

state_t nxt_state, curr_state;
// state flipflop
always_ff @(posedge clk, negedge rst_n) begin
    if (!rst_n)
        curr_state <= NADA;
    else
        curr_state <= nxt_state;
end
// State combinational logic
always_comb begin
    case (curr_state)
        NADA: begin
			if (~diff) begin
				nxt_state = NADA;
				cnt_en = 0;
				clr_cnt = 1;
			end
			else begin
                nxt_state = COUNTING;
                cnt_en = 1;
				clr_cnt = 0;
			end
        end
        COUNTING: begin
            if(~(&cnt)) begin  // if not finished counting, stay in the counting state
                nxt_state = COUNTING;
                cnt_en = 1;
                clr_cnt = 0;
            end
            else begin
                nxt_state = NADA;
                cnt_en = 0;
                clr_cnt = 1;
            end
        end
        default: begin
            cnt_en = 0;
            nxt_state = NADA;
            curr_state = NADA;
        end
    endcase
end
// Counter
always_ff @(posedge clk, negedge rst_n) begin
    if (~rst_n) begin
        cnt = 0;
    end
    else begin
        if (cnt_en) begin
            cnt = cnt+1;
        end
        else begin
            cnt = 0;
        end
    end
end

endmodule