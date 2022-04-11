module nonoverlap (
    input clk, rst_n, highIn, lowIn,
    output reg highOut, lowOut
);

logic hff1, hff2, hff3; // FFs used to remove glitch and detect changes in high signal
logic lff1, lff2, lff3; // FFs used to remove glitch and detect changes in low signal

logic [4:0] cnt;  // counter used to count 32 clk cycles
logic cnt_en;

always_ff @(posedge clk, rst_n) begin
    if (~rst_n) begin
        highOut <= 1'b0;
        lowOut <= 1'b0;
    end
    else begin
        hff1 <= highIn;
        hff2 <= hff1;
        hff3 <= hff2;

        lff1 <= lowIn;
        lff2 <= lff1;
        lff3 <= lff2;
        if ((hff3 != hff2) || (lff3 != lff2)) begin // if there's changes
            highOut <= 1'b0;
            lowOut <= 1'b0;
            cnt_en = 1'b1;
            if (&cnt) begin
                cnt_en = 1'b0;
            end
        end
        else begin
            highOut <= hff3;
            lowOut <= hff3;
            cnt_en = 1'b0;
        end
    end
end

always_comb begin
    while (cnt_en) begin
        if (&cnt) begin  // if cnt has counted to full, reset to zero and disenable the enable signal
            cnt = 0;
        end
        else begin
            cnt = cnt;
        end
    end
end

endmodule