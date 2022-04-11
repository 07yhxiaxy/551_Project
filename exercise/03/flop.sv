module flop(
    output q,
    input clk, d
);
// Declare needed logic
wire md, mq, sd, so, tmp1; // Check if able to declare as wore
// Declare gates
notif1 #1 (md, d, clk);
not (mq, md);
not (weak0, weak1) (md, mq);
not (tmp1, clk);
notif1 #1 (sd, mq, tmp1);
not (so, sd);
not (weak0, weak1) (sd, so);

assign q = so;

endmodule