module rshr_16_tb();

reg [15:0] src;
wire [15:0] res;
reg [3:0] amt;
reg ars;

rshr_16 shifter1 (.src(src), .res(res), .amt(amt), .ars(ars));

initial begin
    src = 16'h0000;
    amt = 4'h0;
    ars = 1'b0;

    // test 1
    src = 16'hABCD;
    amt = 4'h7;
    ars = 1'b1;
    #25;
    if (res != 16'hFFCD)
        $display("error found");
        $stop;

end

endmodule