module mtr_drv(
    input [10:0] duty,
    input clk, rst_n,
    input [1:0] selGrn, selYlw, selBlu,
    output highGrn, lowGrn, highYlw, lowYlw, highBlu, lowBlu, PWM_synch
);

logic highgrntmp, lowgrntmp, highylwtmp, lowylwtmp, highblutmp, lowblutmp;
logic pwm_synch, pwm_sig;

PWM pwm1(.clk(clk), .rst_n(rst_n), .duty(duty), .PWM_sig(pwm_sig), .PWM_synch(pwm_synch));

// Avoid overlap for RYB signals
nonoverlap no_grn(.clk(clk), .rst_n(rst_n), .highIn(highgrntmp), .lowIn(lowgrntmp), .highOut(highGrn), .lowOut(lowGrn));
nonoverlap no_ylw(.clk(clk), .rst_n(rst_n), .highIn(highylwtmp), .lowIn(lowylwtmp), .highOut(highYlw), .lowOut(lowYlw));
nonoverlap no_blu(.clk(clk), .rst_n(rst_n), .highIn(highblutmp), .lowIn(lowblutmp), .highOut(highBlu), .lowOut(lowBlu));

assign highgrntmp = (selGrn == 2'b01) ? ~pwm_sig :
                    (selGrn == 2'b10) ? pwm_sig : 1'b0;

assign highylwtmp = (selGrn == 2'b01) ? ~pwm_sig :
                    (selGrn == 2'b10) ? pwm_sig : 1'b0;

assign highblutmp = (selGrn == 2'b01) ? ~pwm_sig :
                    (selGrn == 2'b10) ? pwm_sig : 1'b0;

assign lowgrntmp =  (selGrn == 2'b01) ? pwm_sig :
                    (selGrn == 2'b10) ? ~pwm_sig :
                    (selGrn == 2'b11) ? pwm_sig : 1'b0;

assign lowylwtmp =  (selGrn == 2'b01) ? pwm_sig :
                    (selGrn == 2'b10) ? ~pwm_sig :
                    (selGrn == 2'b11) ? pwm_sig : 1'b0;

assign lowblutmp =  (selGrn == 2'b01) ? pwm_sig :
                    (selGrn == 2'b10) ? ~pwm_sig :
                    (selGrn == 2'b11) ? pwm_sig : 1'b0;

endmodule