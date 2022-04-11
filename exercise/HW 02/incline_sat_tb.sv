module incline_sat_tb ();

reg signed [12:0] inc;
logic signed [9:0] inc_sat;

incline_sat i1 (.incline(inc), .incline_sat(inc_sat));

initial begin
    inc = 13'h1000;
    #5;
    while ($signed(inc) < $signed(13'h0FFF)) 
        begin
            inc = inc + 1'b1;
            #5;
            if ($signed(inc) <= $signed(10'h200))
                begin
                    if (inc_sat != 10'h200)
                        begin
                            $display("error present 1");
                            $display("inc value is: %d\nwhile inc_sat value is: %d", inc, inc_sat);
                            $stop();
                        end
                end
            if ($signed(inc) >= $signed(10'h1FF))
                begin
                    if(inc_sat != 10'h1FF)
                        begin
                            $display("error present 2");
                            $display("inc value is: %d\nwhile inc_sat value is: %d", inc, inc_sat);
                            $stop();
                        end
                end
            if ($signed(inc) > $signed(10'h200) && $signed(inc) < $signed(10'h1FF))
                begin
                    if (inc_sat != inc[9:0])
                        begin
                            $display("error present 3");
                            $display("inc value is: %d\nwhile inc_sat value is: %d", inc, inc_sat);
                            $stop();
                        end
                end
        end
end

endmodule