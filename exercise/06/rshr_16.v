module rshr_16(
    input [15:0] src,
    input [3:0] amt,
    input ars,
    output [15:0] res
);

// implement the arithmetic right shifts
wire [15:0] astg1, astg2, astg3, astg4;
assign astg1 = amt[0] ? {src[15], src[15:1]} : src;
assign astg2 = amt[1] ? {{2{src[15]}}, astg1[15:2]} : astg1;
assign astg3 = amt[2] ? {{4{src[15]}}, astg2[15:4]} : astg2;
assign astg4 = amt[3] ? {{8{src[15]}}, astg3[15:8]} : astg3;

// implement the logical right shifts
wire [15:0] lstg1, lstg2, lstg3, lstg4;
assign lstg1 = amt[0] ? {1'b0, src[15:1]} : src;
assign lstg2 = amt[1] ? {2'b0, lstg1[15:2]} : lstg1;
assign lstg3 = amt[2] ? {4'b0, lstg2[15:4]} : lstg2;
assign lstg4 = amt[3] ? {8'b0, lstg3[15:8]} : lstg3;

assign res = ars ? astg4 : lstg4;

endmodule