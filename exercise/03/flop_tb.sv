module flop_tb();

logic q, clk, D;

flop f1 (.q(q), .d(D), .clk(clk));

initial begin

    D = 0;
    clk = 0;

    @(posedge clk);
    D = 1;
    #30;

    @(posedge clk);
    D = 0;
    #30;

    @(negedge clk);
    D = 1;
    #25;

    #5;
    $stop();
end

always
    #5 clk = ~clk;

always
    #20 D = ~D;
    
    
endmodule