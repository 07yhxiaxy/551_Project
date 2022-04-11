// Wrong because there's no input in sensitivity list, which should be in the sensitivity list. And the if in always block should include data.

// Problem 3C)
module dff(d, clk, q, set, en);
 input d, clk, set, en;
 output reg q;
 
always @(posedge clk) begin
    if (set) begin
        q <= 1'b1;
    end
    if (en) begin
        q <= d;
    end
end

endmodule

// Problem 3D)
module dff(d, clk, q, reset, en);
 input d, clk, set, en;
 output reg q;
 
always @(posedge clk, reset) begin
    if (~reset) begin
        q <= 1'b0;
    end
    if (en) begin
        q <= d;
    end
end

// Problem 3F)
module ff(d, clk, q, set, clr, rst_n);
    input d, clk, set, clr, rst_n;
    output q;
    always @(posedge clk, rst_n)begin
        if(~rst_n) begin
            q <= 1'b0;
        end
        if (clr) begin
            q <= 1'b0;
        end
        if (set) begin
            q <= 1'b1;
        end
    end
endmodule