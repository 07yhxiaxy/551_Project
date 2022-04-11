module brushless(
    input clk, rst_n, hallGrn, hallYlw, hallBlu, brake_n, PWM_synch,
    input [11:0] drv_mag,
    output logic [10:0] duty,
    output logic [1:0] selGrn, selYlw, selBlu
);

localparam 	for_curr = 2'b10,
			rev_curr = 2'b01,
			high_z = 2'b00,
			regen_braking = 2'b11,
			rb_duty = 11'h600;

// --------------- DOUBLE SYNCH MODULE------------------------------------
reg halgrn1, halgrn2, halylw1, halylw2, halblu1, halblu2, synchGrn, synchYlw, synchBlu;
wire [2:0] rotation_state;

// Get those signals double floped
always_ff @(posedge clk) begin
    halgrn1 <= hallGrn;
    halgrn2 <= halgrn1;
    halylw1 <= hallYlw;
    halylw2 <= halylw1;
    halblu1 <= hallBlu;
    halblu2 <= hallBlu;
end
// set the output to synch_color
always_ff @(posedge clk, negedge rst_n) begin
    if (~rst_n) begin
        synchGrn <= 0;
        synchBlu <= 0;
        synchYlw <= 0;
    end
    else if (PWM_synch) begin
        synchGrn <= halgrn2;
        synchYlw <= halylw2;
        synchBlu <= halblu2;
    end

end

assign rotation_state = {synchGrn, synchYlw, synchBlu};

// --------------- SEL combinational logics------------------------------------
always_comb begin
    if(brake_n) begin
        case (rotation_state)
            3'b101: begin
                selBlu = high_z;
                selYlw = rev_curr;
                selGrn = for_curr;
            end
            3'b100: begin
                selBlu = rev_curr;
                selYlw = high_z;
                selGrn = for_curr;
            end
            3'b110: begin
                selBlu = rev_curr;
                selYlw = for_curr;
                selGrn = high_z;
            end
            3'b010: begin
                selGrn = rev_curr;
                selYlw = for_curr;
                selBlu = high_z;
            end
            3'b011: begin
                selGrn = rev_curr;
                selYlw = high_z;
                selBlu = for_curr;
            end
            3'b001: begin
                selGrn = high_z;
                selYlw = rev_curr;
                selBlu = for_curr;
            end
            default: begin
                selGrn = high_z;
                selBlu = high_z;
                selYlw = high_z;
            end
        endcase
    end
    else begin
        selGrn = regen_braking;
        selYlw = regen_braking;
        selBlu = regen_braking;
    end
end
// --------------- DUTY part------------------------------------
assign duty = brake_n ? (drv_mag[11:2] + 11'h400) : rb_duty;

endmodule