module telemetry (
    input clk, rst_n,
    input [11:0] batt_v, avg_curr, avg_torque,
    output reg TX
);

logic [7:0] tx_data;  // Input for UART module that has 1 byte data
logic trmt;  // Input for UART module that tells when to transmit serial data
logic tx_done;  // Output from UART, tx is a single bit data that transferred, tx_done tells that UART finished serial transfer

UART_tx uart(.clk(clk), .rst_n(rst_n), .TX(TX), .trmt(trmt), .tx_data(tx_data), .tx_done(tx_done));

localparam  // 9 states are required for Mealy
    IDLE = 4'h0,  // IDLE state that counts for 1/48 sec
    DEL1 = 4'h1,  // Delim 1 that sents 0xAA
    DEL2 = 4'h2,  // Delim 2 that sents 0x55
    P1 = 4'h3,  // Payload 1-6 for P1-P6
    P2 = 4'h4,
    P3 = 4'h5,
    P4 = 4'h6,
    P5 = 4'h7,
    P6 = 4'h8,
    NADA = 4'h9;

reg [3:0] state_reg, state_next;  // Regs that store the states

logic cnt_done;  // Signals for the counter that counts 1/48
logic [19:0] cnt;  // Counter that counts 1/47.68 s

assign cnt_done = &cnt;

// ################################# FSM ###########################################

// Loop through all states and give the reset state
always @(posedge clk, rst_n) begin
    if (~rst_n) begin
        state_reg <= NADA;
    end
    else begin
        state_reg <= state_next;
    end
end

// Mealy FSM Design that sents 8 bytes
always @(posedge clk, state_reg, cnt_done, tx_done) begin
    case (state_reg)
        IDLE: // Constantly check cnt_done, if done, proceed to DEL1
            if (~cnt_done) begin // If ~1/48 passed, we want to transfer the next 8 bytes
                state_next <= IDLE; // otherwise remain in same state.
                trmt = 0;
            end
            else begin
                state_next <= NADA;
                trmt = 1;
            end
        NADA: begin // reset to this state
            state_next <= DEL1;
            trmt = 0;
            tx_data = 8'hAA;  // Start transfer the data
        end
        DEL1:
            if (tx_done) begin  // if transmission done, start transmitting the next byte
                state_next <= DEL2;
                tx_data = 8'h55;
                trmt = 1;
            end
        DEL2:
            if (tx_done) begin
                state_next <= P1;
                tx_data = {4'h0, batt_v[11:8]};
                trmt = 1;
            end
        P1:
            if (tx_done) begin
                state_next <= P2;
                tx_data = batt_v[7:0];
                trmt = 1;
            end
        P2:
            if (tx_done) begin
                state_next <= P3;
                tx_data = {4'h0, avg_curr[11:8]};
                trmt = 1;
            end
        P3:
            if (tx_done) begin
                state_next <= P4;
                tx_data = avg_curr[7:0];
                trmt = 1;
            end
        P4:
            if (tx_done) begin
                state_next <= P5;
                tx_data = {4'h0, avg_torque[11:8]};
                trmt = 1;
            end
        P5:
            if (tx_done) begin
                state_next <= P6;
                tx_data = avg_torque[7:0];
                trmt = 1;
            end
        P6:
            if (tx_done) begin
                state_next <= IDLE;
                trmt = 0;
            end
    endcase
end
// ################################# FSM  ENDS ##########################################

// 20 bit counter that stores the ticks, involving reset and check completion logics
always_ff @(posedge clk, rst_n) begin
    if (~rst_n) begin
       cnt <= 0;
    end
    else begin
       cnt <= cnt + 1;
    end
end

endmodule