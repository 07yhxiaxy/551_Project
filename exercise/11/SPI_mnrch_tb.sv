module SPI_mnrch_tb();

    logic clk, rst_n, SS_n, SCLK, MOSI, MISO, rdy;
    logic [15:0] A2D_data, cmd;

    ADC128S device2 (.clk(clk), .rst_n(rst_n), .SS_n(SS_n), .SCLK(SCLK), .MOSI(MOSI), .MISO(MISO));

    // SPI_ADC128S device1 (.clk(clk), .rst_n(rst_n), .SS_n(SS_n), .SCLK(SCLK), .MISO(MISO), .MOSI(MOSI), .A2D_data(A2D_data), .cmd(cmd), .rdy(rdy));
 
    logic  resp[15:0];
    logic snd, done;

    SPI_mnrch iDUT(.clk(clk), .rst_n(rst_n), .cmd(cmd), .snd(snd), .resp(resp), .done(done), .SS_n(SS_n), .SCLK(SCLK), .MOSI(MOSI), .MISO(MISO));

    // Generate clock signal
    always begin
        #5;
        clk = ~clk;
    end

    initial begin
        clk = 0;
        rst_n = 0;
        snd = 0;
    end
    logic [2:0] chnl;

    always @(posedge clk) begin
        assign chnl = 3'b001;
        cmd = {2'b00,chnl[2:0],11'h000};  // send to channel 3
        #32;
        if (resp != 16'hC00) begin
            $display(" not correct");
            $stop();
        end
        assign chnl = 3'b001;
        cmd = {2'b00,chnl[2:0],11'h000};  // send to channel 3
        #32;
        if (resp != 16'hC01) begin
            $display(" not correct");
            $stop();
        end
        assign chnl = 3'b100;
        cmd = {2'b00,chnl[2:0],11'h000};  // send to channel 3
        #32;
        if (resp != 16'hBF1) begin
            $display(" not correct");
            $stop();
        end
        assign chnl = 3'b100;
        cmd = {2'b00,chnl[2:0],11'h000};  // send to channel 3
        #32;
        if (resp != 16'hBF4) begin
            $display(" not correct");
            $stop();
        end
    end

endmodule