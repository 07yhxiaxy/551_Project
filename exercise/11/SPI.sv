module SPI_mnrch(
	input clk, rst_n,
	input MISO, snd,
	input [15:0] cmd,
	output logic SS_n, SCLK, MOSI, done,
	output logic [15:0] resp
);

typedef enum logic[1:0] {IDLE, SHIFTING, BEFORE_DONE} state_t;
state_t state, next_state;

logic [15:0] shift_register;
logic [4:0]  SCLK_div;
logic [5:0]  bit_cntr;
logic ld_SCLK, init, shft, done;

// Define the state machine
always_ff @(posedge clk, negedge rst_n) begin
	if (!rst_n) 
         	state <= IDLE;
       else
			state <= next_state;
end

// State machine combinational logic
always_comb begin
	case (state)
		IDLE: begin
			ld_SCLK = 1;
			done = 0;
			if (snd) begin
		      	next_state = SHIFTING;
			init = 1;
		        end
			else begin
		           next_state = IDLE;
		           init = 0;
		        end
	      end
	      SHIFTING: begin
		      init = 0;
		      ld_SCLK = 0;
		      done = 0;
		      if (done16)
			      next_state = BEFORE_DONE;
		      else
			      next_state = SHIFTING;
	      end
	      BEFORE_DONE: begin
		      init = 0;
		      ld_SCLK = 0;
		      if (SCLK_div == 5'b10110) begin
			      next_state = IDLE;
			      done = 1;
		      end
		      else begin
			      next_state = BEFORE_DONE;
			      done = 0;
		      end
	      end
      endcase
      resp = shift_register;
end

// Synch with SCLK
always_ff @(posedge clk, negedge rst_n) begin
	if (!rst_n) 
		SCLK_div <= 5'b10111;
	else if (ld_SCLK)
		SCLK_div <= 5'b10111;
	     else
		SCLK_div <= SCLK_div + 5'b00001;
end
assign SCLK = SCLK_div[4];

// Implement SS_n
always_ff @(posedge clk, negedge rst_n) begin
	if (!rst_n) 
		SS_n <= 1;
	else
		if (init)
			SS_n <= 0;
		else if (done)
		       SS_n <= 1;
			else
				SS_n <= SS_n;
end

// Implement shift register
always_ff @(posedge clk, negedge rst_n) begin
        if (!rst_n) 
	   shift_register <= 0;	
	else if (init)
		shift_register <= cmd;
	     else if (shft)
		shift_register <= {shift_register[14:0], MISO};
	     else
		shift_register <= shift_register;
end

assign MOSI = shift_register[15];

// Implement bit counter
always_ff @(posedge clk) begin
       if (init)
          bit_cntr <= 4'b0000;
       else if (shft)
	     bit_cntr <= bit_cntr + 4'b0001;
            else 
             bit_cntr <= bit_cntr;
end  
assign done16 = bit_cntr[4] & (~|bit_cntr[3:0]);
assign shft = (SCLK_div == 5'b10001) ? 1'b1 : 1'b0;

endmodule
