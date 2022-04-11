module PWM (
    input clk, rst_n,
    input [10:0] duty,
    output reg PWM_sig, PWM_synch
);

logic [10:0] cnt;

assign PWM_synch = (cnt == 11'h001) ? 1'b1 : 1'b0;

always_ff @(posedge clk, rst_n) begin
    if (~rst_n) begin
        PWM_sig <= 1'b0;
        cnt <= 1'b0;
    end
    else begin
        PWM_sig <= (cnt <= duty) ? 1'b1 : 1'b0;
        cnt <= cnt + 1;
    end

end

endmodule