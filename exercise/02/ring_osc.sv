module  ring_osc (
    output OUT,
    input EN
);

logic out, n1, n2;

nand #5 (n1, EN, out);
not #5 (n2, n1);
not #5 (out, n2);

assign OUT = out;
    
endmodule