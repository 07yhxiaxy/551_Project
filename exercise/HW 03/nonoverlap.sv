module nonoverlap (
    input clk, rst_n, highIn, lowIn,
    output reg highOut, lowOut
);

logic hff1, hff2; // FFs used to detect changes in high signal
logic lff1, lff2; // FFs used to detect changes in low signal

logic [4:0] cnt;  // counter used to count 32 clk cycles
logic cnt_en, change;

reg state_reg, nxt_state;

localparam  DETECT = 0,
            COUNT = 1;

always @(posedge clk, rst_n) // always block to update state
    if (~rst_n)
        state_reg <= DETECT;
    else
        state_reg <= nxt_state;

// FFs that detect the change in signals
always_ff @(posedge clk, rst_n) begin
    if (~rst_n) begin
        highOut <= 1'b0;
        lowOut <= 1'b0;
    end
    else begin
        hff1 <= highIn;
        hff2 <= hff1;

        lff1 <= lowIn;
        lff2 <= lff1;
        if ((hff1 != hff2) || (lff1 != lff2)) begin // if there's changes
            change = 1;
        end
        else begin
            highOut <= hff2;
            lowOut <= lff2;
            change = 0;
        end
    end
end

always_ff @(posedge clk, change) begin
    case (state_reg)
        DETECT: begin
            cnt_en = 0;
            if (change) begin
                nxt_state <= COUNT;
                cnt_en = 1;
            end
            else begin
                nxt_state <= state_reg;
            end
        end
        COUNT: begin
            if (&cnt) begin
                nxt_state <= DETECT;
                cnt_en = 0;
            end
            else begin
                nxt_state <= COUNT;
            end
        end
    endcase
end

always_ff @(posedge clk) begin
    if (cnt_en) begin
        cnt = cnt + 1;
    end
    else begin
        cnt = 0;
    end
end

endmodule