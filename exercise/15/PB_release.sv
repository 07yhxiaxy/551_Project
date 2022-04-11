module PB_release(
    input clk, rst_n, PB,
    output released
);

logic dff1, dff2, dff3;

always_ff @(posedge clk, negedge rst_n) begin
    if (~rst_n) begin
        dff1 <= 1'b1;
        dff2 <= 1'b1;
        dff3 <= 1'b1;
    end
    else begin
        dff1 <= PB;
        dff2 <= dff1;
        dff3 <= dff2;
    end
end

assign released = ~dff3 & dff2;

endmodule