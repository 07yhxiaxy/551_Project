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

incline_sat i1( .incline(incline), .incline_sat(inc_sat));

logic [10:0] incline_factor;
assign incline_factor = {inc_sat[9], inc_sat[9:0]} + 256;

logic [8:0] incline_factor_limit;
assign incline_factor_limit = (incline_factor[10] == 1'b1) ? 9'h000 : (incline_factor[9]) ? 9'h1FF : incline_factor[8:0];

logic [5:0] cadence_factor;
assign cadence_factor = (|cadence[4:1]) ? (cadence + 32) : 6'h00;

logic [12:0]torque_off;
assign torque_off = {1'b0, avg_torque} - {1'b0, TORQUE_MIN};

logic [12:0] torque_pos;
assign torque_pos = (torque_off[12] == 1'b1) ? 12'hFFF : torque_off[11:0];

logic [30:0]assist_prod;
assign assist_prod = not_pedaling ? 30'h00000000 : (torque_pos * incline_factor_limit * cadence_factor * scale);

assign target_curr = (|assist_prod[29:27]) ? 12'hFFF : assist_prod[26:15];


endmodule