module PWM_tb();

logic clk, rst_n;
logic [10:0] duty;
logic PWM_sig, PWM_synch;

PWM iDUT(.clk(clk), .rst_n(rst_n), .duty(duty), .PWM_synch(PWM_sig), .PWM_sig(PWM_synch));

initial begin
    clk = 1'b0;
    rst_n = 1'b0;
    duty = 11'h200;
    repeat(2048) @(negedge clk) begin
        rst_n = 1'b1;
    end

    rst_n = 1'b0;
    duty = 11'h290;
    repeat(2048) @(negedge clk) begin
        rst_n = 1'b1;
    end

    rst_n = 1'b0;
    duty = 11'h400;
    repeat(2048) @(negedge clk) begin
        rst_n = 1'b1;
    end

    rst_n = 1'b0;
    duty = 11'h790;
    repeat(2048) @(negedge clk) begin
        rst_n = 1'b1;
    end

    $stop();
end

always begin
    clk = ~clk;
    #5;
end

endmodule