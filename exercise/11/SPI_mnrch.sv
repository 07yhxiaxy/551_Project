// module SPI_mnrch(
//     input clk, rst_n, MISO, snd,
//     output reg SS_n, done,
//     output reg SCLK, MOSI,
//     input [15:0] cmd,
//     output reg resp[15:0]
// );

// logic [15:0] shft_reg;
// logic [4:0] bit_cntr, SCLK_div;
// logic ld_SCLK, full, shft, init;

// logic shft_tmp, done_tmp, SSn_tmp, done16;
// logic [15:0] shft_reg_tmp;
// logic [4:0] sclk_div_tmp;
// logic [15:0] dn16_shft, dn16_init;

// always_ff @(posedge clk, rst_n) begin
//     if (~rst_n) begin
//         bit_cntr <= 5'h00;
//         SS_n <= 0;
//         done <= 0;
//     end
//     shft_reg <= shft_reg_tmp;
//     SCLK <= sclk_div_tmp;
//     bit_cntr <= dn16_init;
//     SS_n <= SSn_tmp;
//     done <= done_tmp;
//     MOSI <= shft_reg[15];
//     // resp <= shft_reg;
// end

// always_comb begin
//     shft_reg_tmp = init ? cmd[15:0] : {init,shft} == 2'b01 ? {shft_reg[14:0],MISO} : shft_reg;
//     sclk_div_tmp = ld_SCLK ? 5'b10111 : (SCLK_div+1);
//     full = SCLK_div[4];
//     shft = (SCLK == 5'b10001);
//     dn16_shft = shft ? bit_cntr + 1 : bit_cntr;
//     dn16_init = init ? 5'h00 : dn16_shft;
//     done16 = &bit_cntr;
// end

// endmodule

module SPI_mnrch (
    input clk,rst_n;  
    input MISO;	
    input snd;
    input [15:0] cmd;
    output logic SS_n;
    output SCLK, MOSI;
    output done;
    output [15:0] resp;
);

logic [15:0] shft_reg;  // value in shift register
logic init, shift;  // fsm states
logic done_tmp, done_flag;  // temporary values that saves done flags
logic done;  // assert when shift is done

logic [4:0] bit_cntr;  // count how many times shift register shifted
logic [4:0] SCLK_div;  // count the clk / 32 to match the SLCK
logic ld_SCLK;  //  inform start of the SLCK

typedef enum reg [1:0] {IDLE, SHIFT, DONE} state_t;
state_t state_reg, nxt_state;

//bit counter to count the shift register shifted
always_ff @(posedge clk or negedge rst_n) begin
    if (~rst_n)
        bit_cntr <= 0;
    else if (init)
        bit_cntr <= 5'b00000; // initiate the bit counter		
    else begin
    if (shift)
        bit_cntr <= bit_cntr + 1; // count shift times
    end
end

assign done_flag = bit_cntr[4]; // mark done flag when bits have been shifted

// SLCK counter
always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        SCLK_div <= 0;
    else if (ld_SCLK)  // initiate the SLCK
        SCLK_div <= 5'b10111;			
    else 
        SCLK_div <= SCLK_div + 1; // counting clk
    end

assign shift = (SCLK_div == 5'b10111) ? 1'b1 : 1'b0; // inform to shift two clk after rise

assign SCLK = SCLK_div[4];  // assert SCLK

assign MOSI = shft_reg[15];  // shift MSB to MOSI

// shifter ffs to shift MOSI and MISO
always_ff @(posedge clk, negedge rst_n) begin
    if (!rst_n)
        shft_reg <= 0;
    else if (init)
        shft_reg <= cmd;
    else if(shift)
        shft_reg <= {shft_reg[14:0], MISO};
end

assign resp = shft_reg;  // read from shift register

// indicate if shift is done
always_ff @(posedge clk, negedge rst_n) begin
    if (!rst_n)
        done <= 1'b0;
    else if (init)
        done <= 1'b0;
    else if(done_tmp)
        done <= 1'b1;
end

// show SS_n
always_ff @(posedge clk, negedge rst_n) begin
    if (~rst_n)
        SS_n <= 1'b1;
    else if (init)  // set SS_n to low at init
        SS_n <= 1'b0;			
    else if(done_tmp)  //set SS_n to high if done
        SS_n <= 1'b1;
end

// ####################### FSM LOGIC ##############################

// gives next state ff
always_ff @(posedge clk, negedge rst_n) begin
    if (~rst_n)
        state_reg <= IDLE;
    else
        state_reg <= nxt_state;
end

// FSM logic
always_comb begin
    init = 1'b0;
    ld_SCLK = 1'b0;
    done_tmp = 1'b0;
    nxt_state = state_reg;
	case (state_reg)
	IDLE: begin
		ld_SCLK = 1'b1;
		if (snd) begin
                init = 1'b1;
                nxt_state = SHIFT;
            end
        end

	SHIFT: begin  // keep counting until shift finishes
		if (done_flag)
		nxt_state = DONE;
	end
	DONE: begin
		if (&SCLK_div) begin  
                done_tmp = 1'b1;
		        ld_SCLK = 1'b1;
                nxt_state = IDLE;
            end
        end     
        default: begin
	        nxt_state = state_reg;
	    end
   endcase
end

// ####################### FSM LOGIC ENDS ##############################

endmodule