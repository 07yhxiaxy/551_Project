module PWM (
    input clk, rst_n,
    input [10:0] duty,
    output reg PWM_sig, PWM_synch
);

logic [10:0] cnt;

assign PWM_synch = (cnt == 11'h001) ? 1'b1 : 1'b0;

// PWM signal flipflop
always_ff @(posedge clk, negedge rst_n) begin
    if (~rst_n) begin
        PWM_sig <= 1'b0;
    end
    else begin
        PWM_sig <= (cnt <= duty) ? 1'b1 : 1'b0;
    end
end

// Counter flipflop
always_ff @(posedge clk, negedge rst_n) begin
    if (~rst_n) begin
        cnt <= 11'h000;
    end
    else begin
        cnt <= cnt + 1;
    end
end

endmodule