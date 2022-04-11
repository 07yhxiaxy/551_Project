module synch_detect (
    input asynch_sig_in, clk,
    output rise_edge
);

wire tmp1, tmp2, tmp3, tmp4;

dff d1 (.clk(clk), .D(asynch_sig_in), .Q(tmp1));
dff d2 (.clk(clk), .D(tmp1), .Q(tmp2));
dff d3 (.clk(clk), .D(tmp2), .Q(tmp3));

not(tmp4, tmp3);
and (rise_edge, tmp2, tmp4);

endmodule