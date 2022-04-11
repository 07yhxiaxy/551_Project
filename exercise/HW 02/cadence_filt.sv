module cadence_filt(
    input clk, rst_n, cadence,
    output reg cadence_filt, cadence_rise
);

logic cd_flop1, cd_flop2, cd_flop3;
logic chngd_n;
logic cd_fit_tmp1;
logic [15:0] stbl_cnt;
logic stable;
logic [15:0] np1, tmp1;

always_ff @(posedge clk, negedge rst_n) begin
    // Check async neg reset signal
    // If not asserted, reset all ff.
    if (~rst_n) begin
        stbl_cnt <= 16'h0000;
        cadence_filt <= 1'b0;
        cd_flop1 <= 1'b0;
        cd_flop2 <= 1'b0;
        cd_flop3 <= 1'b0;
    end
    else begin
        cd_flop1 <= cadence;
        cd_flop2 <= cd_flop1;
        cd_flop3 <= cd_flop2;
        cadence_filt <= cd_fit_tmp1;
        stbl_cnt <= tmp1;
    end

end

always_comb begin
    // Detect change in signal and if it rises
    cadence_rise = cd_flop2 & ~cd_flop3;
    chngd_n = ~(cd_flop3 ^ cd_flop2);
    // Counter that counts about 1ms
    np1 = stbl_cnt + 1'b1;
    // and chngd_n with n + 1 to detect if there's any change to the signal.
    tmp1 = {16{chngd_n}} & np1;
    // Detects if it passes roughly 1ms and outputs cadence_filt
    stable = &stbl_cnt;
    // Choose which data to feed back to the ff.
    cd_fit_tmp1 = stable ? cd_flop3 : cadence_filt;

end

endmodule