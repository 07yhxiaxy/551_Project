module reset_synch(
    input RST_n, clk,
    output reg rst_n
);

logic dff1;

always_ff @(negedge clk, negedge RST_n) begin
    if (~RST_n) begin
        dff1 <= 1'b0;
        rst_n <= 1'b0;
    end
    else begin
        dff1 <= 1'b1;
        rst_n <= dff1;
    end
end

endmodule