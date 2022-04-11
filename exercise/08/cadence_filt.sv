module cadence_filt(
    input clk, rst_n, cadence,
    output cadence_filt, cadence_rise
);

logic cd_flop1, cd_flop2, cd_flop3;
logic chngd_n;
logic cd_fit_tmp, stbl_cnt_check, tmp, cdrise_tmp, cd_fit_tmp2;
logic [16:0] stbl_cnt, np1, tmp1;
always_ff @(posedge clk) begin
    cd_flop1 <= cadence;
    cd_flop2 <= cd_flop1;
    cd_flop3 <= cd_flop2;
    cd_fit_tmp2 <= cd_fit_tmp;
    stbl_cnt <= tmp1;
end

assign cadence_filt = cd_fit_tmp2;

always_comb begin
    // Detect change in signal and if it rises
    cdrise_tmp = cd_flop2 & ~cd_flop3;
    chngd_n = ~(cd_flop3 ^ cd_flop2);
    // Detects if it passes roughly 1ms and outputs cadence_filt
    cd_fit_tmp = stbl_cnt_check ? cd_flop3 : cadence_filt;
    // Counter that counts about 1ms
    tmp1 = {17{chngd_n}} & np1;
    np1 = stbl_cnt + 1'b1;
    stbl_cnt_check = &stbl_cnt;
end

assign cadence_rise = cdrise_tmp;

endmodule