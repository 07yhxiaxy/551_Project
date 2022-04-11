module shifter(
    input [15:0] src,
    input [3:0] amt,
    input ars,
    output [15:0] res
);
// Implement a shifter
// Create temporary values for manipulating bits
logic signed [15:0] ars_level1, ars_level2, ars_level3, ars_level4, lrs_level1, lrs_level2, lrs_level3, lrs_level4;

// Perform arithmatic right shifter
assign ars_level1 = amt[0] ? {src[15],src[15:1]} : src;
assign ars_level2 = amt[1] ? {{2{ars_level1[15]}},ars_level1[15:2]} : ars_level1;
assign ars_level3 = amt[2] ? {{4{ars_level1[15]}},ars_level2[15:4]} : ars_level2;
assign ars_level4 = amt[3] ? {{8{ars_level1[15]}},ars_level3[15:8]} : ars_level3;
// Perform logical right shifter
assign lrs_level1 = amt[0] ? {1'b0,src[15:1]} : src;
assign lrs_level2 = amt[1] ? {2'b0,lrs_level1[15:2]} : lrs_level1;
assign lrs_level3 = amt[2] ? {4'b0,lrs_level2[15:4]} : lrs_level2;
assign lrs_level4 = amt[3] ? {8'b0,lrs_level3[15:8]} : lrs_level3;
// Select the outcome we want to output
assign res = ars ? ars_level4 : lrs_level4;

endmodule