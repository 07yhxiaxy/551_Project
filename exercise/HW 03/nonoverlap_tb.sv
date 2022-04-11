module nonoverlap_tb();

logic li, lo, ho, clk, rst_n;

nonoverlap iDUT (.lowIn(li), .highIn(~li), .lowOut(lo), .highOut(ho), .clk(clk), .rst_n(rst_n));

initial begin
    li <= 1'b0;
    clk <= 1'b0;
    rst_n <= 0;
    #5
    rst_n <= 1;
    li <= 1'b1;
    #160;
    li <= 1'b0;
    #160;
    li <= 1'b1;
    #160;
    $stop();
end

always begin
    #5;
    assign clk = ~clk;
end

endmodule