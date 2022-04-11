module nonoverlap_tb();

logic li, lo, ho, clk, rst_n;

nonoverlap iDUT (.lowIn(li), .highIn(~li), .lowOut(lo), .highOut(ho), .clk(clk), .rst_n(rst_n));

initial begin
    li <= 1'b0;
    clk <= 1'b0;
end

always begin
    #5;
    assign clk = ~clk;
end

always begin  // self-checking later
    li <= 1'b1;
    #160;
    li <= 1'b0;
    #160;
    li <= 1'b1;
    #160;
    $stop();
end

endmodule