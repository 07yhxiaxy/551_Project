module brushless(
    input clk, rst_n, hallGrn, hallYlw, hallBlu, brake_n, PWM_synch,
    input [11:0] drv_mag,
    output logic [10:0] duty,
    output logic [1:0] selGrn, selYlw, selBlu
);

parameter [1:0] for_curr = 2'b10,
                rev_curr = 2'b01,
                high_z = 2'b00,
                regen_braking = 2'b11;

// --------------- DOUBLE SYNCH MODULE------------------------------------
logic halgrn1, halgrn2, halgrn3, halylw1, halylw3, halylw2, halblu1, halblu2, halblu3, synchGrn, synchYlw, synchBlu;
assign rotation_state = {synchGrn, synchYlw, synchBlu};
// Get those signals double floped
always_ff @(posedge clk) begin
    halgrn1 <= hallGrn;
    halgrn2 <= halgrn1;
    halylw1 <= hallYlw;
    halylw2 <= halylw1;
    halgrn1 <= hallGrn;
    halgrn2 <= halgrn1;
end
// set the output to synch_color
always_ff @(posedge clk, rst_n) begin
    if (~rst_n) begin
        synchGrn <= 0;
        synchBlu <= 0;
        synchYlw <= 0;
    end
    else begin
        synchGrn <= halgrn3;
        synchYlw <= halylw3;
        synchBlu <= halblu3;
    end

end
// Select which signal to feed back
always_comb begin
    halgrn3 = PWM_synch ? halgrn2 : synchGrn;
    halylw3 = PWM_synch ? halylw2 : synchYlw;
    halblu3 = PWM_synch ? halblu2 : synchBlu;
end
// --------------- SEL combinational logics------------------------------------
always_ff @(posedge clk, brake_n) begin
    if (~brake_n) begin
        selGrn <= 2'b11;
        selBlu <= 2'b11;
        selYlw <= 2'b11;
    end
    else begin
        case (rotation_state)
            3'b101: begin
                selBlu <= high_z;
                selYlw <= rev_curr;
                selGrn <= for_curr;
            end
            3'b100: begin
                selBlu <= rev_curr;
                selYlw <= high_z;
                selGrn <= for_curr;
            end
            3'b110: begin
                selBlu <= rev_curr;
                selYlw <= for_curr;
                selGrn <= high_z;
            end
            3'b010: begin
                selGrn <= rev_curr;
                selYlw <= for_curr;
                selBlu <= high_z;
            end
            3'b011: begin
                selGrn <= rev_curr;
                selYlw <= high_z;
                selBlu <= for_curr;
            end
            3'b001: begin
                selGrn <= high_z;
                selYlw <= rev_curr;
                selBlu <= for_curr;
            end
            default: begin
                selGrn <= high_z;
                selBlu <= high_z;
                selYlw <= high_z;
            end
        endcase
    end
end
// --------------- DUTY part------------------------------------
logic [11:0] drv_mag_tmp;

always_comb begin
    drv_mag_tmp = drv_mag + 11'h400;
    duty = brake_n ? drv_mag_tmp[10:0] : 11'h600;
end

endmodule