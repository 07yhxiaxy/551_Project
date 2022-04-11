module desiredDrive(
    input [11:0] avg_torque,
    input [4:0] cadence,
    input not_pedaling,
    input [12:0] incline,
    input [2:0] scale,
    output [11:0] target_curr
);

localparam TORQUE_MIN = 12'h380;
localparam TOO_SMALL = 5'h05;

logic [9:0] inc_sat;

incline_sat( .incline(incline), .incline_sat(inc_sat));

logic [10:0] incline_factor;
assign incline_factor = {inc_sat[9], inc_sat} + 9'b100000000;

logic [8:0] incline_factor_limit;
assign incline_factor_limit = (incline_factor[10] == 1'b1) ? 9'b0 : (incline_factor > 511) ? 9'hFF : incline_factor;

logic [5:0] cadence_factor;
assign cadence_factor = cadence + 4'b1100;

logic [11:0] avg_torque;
logic [12:0]torque_off;
assign torque_off = avg_torque - TORQUE_MIN;

logic [12:0] torque_pos;
assign torque_pos = (torque_off[12] == 1'b1) ? 12'hFFF : torque_off;

logic [29:0]assist_prod;
assign assist_prod = not_pedaling ? 30'h00000000 : (torque_pos * incline_factor_limit * cadence_factor * scale);

assign target_curr = (|assist_prod[29:27]) ? 12'hFFF : assist_prod[26:15];


endmodule