module ring_osc_tb();

logic in, out;

// Instantiate the DUT
ring_osc r1 (.EN(in), .OUT(out));

initial begin
    in = 0;
    #15;
    in = 1;
    #50;
    $stop();
end
endmodule