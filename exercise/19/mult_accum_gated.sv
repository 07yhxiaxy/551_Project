module mult_accum_gated(clk,clr,en,A,B,accum);

input clk,clr,en;
input [15:0] A,B;
output reg [63:0] accum;

reg [31:0] prod_reg;
reg en_stg2;

////////////////////////////////////////////////////
// Generate two latch structures for 2 gated clock//
////////////////////////////////////////////////////
logic clk_en_lat, clk_en_lat2, gated_clk1, gated_clk2;
always @ (~clk or en) begin
      if (~clk)
         clk_en_lat <= en;
end

assign gated_clk1 = clk_en_lat & clk;

always @ (~clk or en_stg2) begin
      if (~clk)
         clk_en_lat2 <= en_stg2;
end

assign gated_clk2 = clk_en_lat2 & clk;

///////////////////////////////////////////
// Generate and flop product if enabled //
/////////////////////////////////////////
always_ff @(posedge gated_clk1)
    // if (en)
    prod_reg <= A*B;

/////////////////////////////////////////////////////
// Pipeline the enable signal to accumulate stage //
///////////////////////////////////////////////////
always_ff @(posedge clk)
    en_stg2 <= en;

always_ff @(posedge gated_clk2)
    if (clr)
      accum <= 64'h0000000000000000;
    else // else if (en_stg2)
      accum <= accum + prod_reg;



endmodule
