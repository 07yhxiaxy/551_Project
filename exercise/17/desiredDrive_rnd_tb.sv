module desiredDrive_rnd_tb();

logic [11:0] avg_torque, target_curr;
logic [2:0] scale;
logic [12:0] incline;
logic not_pedaling;
logic [4:0] cadence;

desiredDrive iDUT(.avg_torque(avg_torque), .cadence(cadence), .not_pedaling(not_pedaling), .incline(incline), .scale(scale), .target_curr(target_curr));

logic [33:0] stim_mem [0:1499];
logic [11:0] resp_mem [0:1499];

integer i;

integer err_cnt;

initial begin
    $readmemh("desiredDrive_stim.hex", stim_mem);  // Get 1500 stimulus entries, and use this later to retrieve output from DUT.
    $readmemh("desiredDrive_resp.hex", resp_mem);
    err_cnt = 0;
    for (i = 0; i < 1500; i = i+1) begin
        // $display("%d:%h", i, stim_mem[i]); // Print all 1500 entries to see if correct
        avg_torque = stim_mem[i][33:22];
        cadence = stim_mem[i][21:17];
        not_pedaling = stim_mem[i][16];
        incline = stim_mem[i][15:3];
        scale = stim_mem[i][2:0];
        #1;
        if (target_curr != resp_mem[i]) begin
            $display("problem with #%d set.", i);
            $display("output target_curr value is %h, but expected %h", target_curr, resp_mem[i]);
            err_cnt = err_cnt + 1;
            $stop();
        end
    end
    $display("Yahoo! Test passed! No errors present!");
end



endmodule