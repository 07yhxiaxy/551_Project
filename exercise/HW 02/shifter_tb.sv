module shifter_tb();

logic signed [15:0] src, res, tmp;
logic [3:0] amt;
logic ars, clk;
logic [15:0] test_numbers [0:5];
assign test_numbers = {16'hFFFF, 16'hAEFF, 16'h0FFF, 16'h001E, 16'h0000, 16'h1234};

shifter s1(.src(src), .ars(ars), .amt(amt), .res(res));

initial begin
    assign src = test_numbers[0];
    assign ars = 1'b1;
    assign amt = 4'h0;
end


// Make a clock
always begin
    assign clk = 1'b1;
    #5;
    assign clk = 1'b0;
    #5;
end

// SELF CHECKING TESTBENCH
always @(posedge clk) begin
    logic [2:0] i;
    logic [4:0] j;
    logic k;
    for(k = 0; k < 2; k = k+1) begin
        assign ars = k;
        #5;
        for(j = 0; j < 16; j = j+1) begin
            for (i = 0; i < 6; i = i+1) begin
                #5;
                assign src = test_numbers[i];
                if (amt == 4'hF) begin
                    $display("finished testing, all correct");
                    $stop();
                end
                if (ars && (res != src >>> amt)) begin
                    assign tmp = src >>> amt;
                    $display("not correct, result is %h, should be %h", res, tmp);
                    $display("src is %h, amt is %h, ars is %b", src, amt, ars);
                    $stop();
                end
                if (~ars && (res != src >> amt)) begin
                    assign tmp = src >> amt;
                    $display("not correct, result is %h, should be %h", res, tmp);
                    $stop();
                end

                if (ars) begin
                    assign tmp = src >>> amt;
                    $display("result is %h, should be %h", res, tmp);
                end
                else begin
                    assign tmp = src >> amt;
                    $display("result is %h, should be %h", res, tmp);
                end
                #5;
                assign amt = j[3:0];
            end
        end
    end
    $stop();
end

// // Non selfchecking test bench
// always begin
//     integer i;
//     assign src = test_numbers[0];
//     for (i = 0; i < 16; i++) begin
//         #5;
//         amt = amt+1;
//         #5;
//     end
//     amt = 4'h0;
//     assign src = test_numbers[1];
//     for (i = 0; i < 16; i++) begin
//         amt = amt+1;
//         #5;
//     end
//     amt = 4'h0;

//     assign src = test_numbers[2];
//     for (i = 0; i < 16; i++) begin
//         amt = amt+1;
//         #5;
//     end
//     amt = 4'h0;

//     assign src = test_numbers[3];
//     for (i = 0; i < 16; i++) begin
//         amt = amt+1;
//         #5;
//     end
//     amt = 4'h0;

//     assign src = test_numbers[4];
//     for (i = 0; i < 16; i++) begin
//         amt = amt+1;
//         #5;
//     end
//     amt = 4'h0;
//     assign src = test_numbers[5];
//     for (i = 0; i < 16; i++) begin
//         amt = amt+1;
//         #5;
//     end
//     $stop();
// end

endmodule