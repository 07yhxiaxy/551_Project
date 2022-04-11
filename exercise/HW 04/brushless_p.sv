module brushless(clk,rst_n,drv_mag,PWM_synch,hallGrn,hallYlw,
                 hallBlu,brake_n,duty,selGrn,selYlw,
                 selBlu);
				 
  input clk;					// 50MHz clock
  input rst_n;					// active low asynch reset
  input [11:0] drv_mag;			// drive magnitude (duty proportional to this)
  input PWM_synch;				// only update commutation at PWM deadband
  input hallGrn;				// hall sensor input Green
  input hallYlw;				// hall sensor input Yellow
  input hallBlu;				// hall sensor input Blue
  input brake_n;
  output logic [10:0] duty;		// Duty cycle of FET drive
  output logic [1:0] selGrn;	// select for green coil (off,low,high)
  output logic [1:0] selYlw;	// select for yellow coil (off,low,high)
  output logic [1:0] selBlu;	// select for blue coil (off,low,high)
  
  localparam HIGH_Z = 2'b00;
  localparam LOW_PWM = 2'b01;
  localparam HIGH_PWM = 2'b10;
  localparam BRAKE = 2'b11;
  localparam BRAKE_DUTY = 11'h600;	// 75% duty cycle for braking
  
  wire [2:0] rotation_state;
  
  reg hallGrn_ff1,hallGrn_ff2,Grn_synch;		// meta-stability flopping &
  reg hallYlw_ff1,hallYlw_ff2,Ylw_synch;		// synch to PWM deadband
  reg hallBlu_ff1,hallBlu_ff2,Blu_synch;
 
 
  //////////////////////////////////////
  // Double flop hall sensor signals //
  // to mitigate meta-stability     //
  ///////////////////////////////////
//   always_ff @(posedge clk)
//     begin
// 	   hallGrn_ff1 <= hallGrn;
// 		hallYlw_ff1 <= hallYlw;
// 		hallBlu_ff1 <= hallBlu;
// 		hallGrn_ff2 <= hallGrn_ff1;
// 		hallYlw_ff2 <= hallYlw_ff1;
// 		hallBlu_ff2 <= hallBlu_ff1;
// 	 end
	 
  //////////////////////////////////////////
  // Now only update commutation when we //
  // know a PWM deadband is approaching //
  ///////////////////////////////////////
  always_ff @(posedge clk, negedge rst_n)
    if (!rst_n) begin
	  Grn_synch <= 1'b0;
	  Ylw_synch <= 1'b0;
	  Blu_synch <= 1'b0;
	end else if (PWM_synch) begin
	  Grn_synch <= hallGrn_ff2;
	  Ylw_synch <= hallYlw_ff2;
	  Blu_synch <= hallBlu_ff2;
	end
	 
  ///////////////////////////////////////////////////////////
  // Make a 3-bit state that represents state of rotation //
  /////////////////////////////////////////////////////////
  assign rotation_state = {Grn_synch,Ylw_synch,Blu_synch};
  
  assign duty = (brake_n) ? 11'h400+drv_mag[11:2] : BRAKE_DUTY;
  
  
  always_comb begin
	if (brake_n) begin			// brake is not asserted
		 case (rotation_state)
		  3'b101 : begin		// green rising edge
			selGrn = HIGH_PWM;	// green driving positive
			selYlw = LOW_PWM;	// yellow driving negative
			selBlu = HIGH_Z;
		  end
		  3'b100 : begin		// 2nd of green high
			selGrn = HIGH_PWM;	// green driving positive
			selYlw = HIGH_Z;	// yellow high impedance
			selBlu = LOW_PWM;	// blue driving negative
		  end
		  3'b110 : begin		// yellow rising edge
			selGrn = HIGH_Z;	// green high impedance
			selYlw = HIGH_PWM;	// yellow driving high
			selBlu = LOW_PWM;	// blue driving negative
		  end
		  3'b010 : begin		// 2nd of yellow high
			selGrn = LOW_PWM;	// green driving negative
			selYlw = HIGH_PWM;	// yellow driving positive
			selBlu = HIGH_Z;	// blue high impedance
		  end
		  3'b011 : begin		// blue rising edge
			selGrn = LOW_PWM;	// green driving negative
			selYlw = HIGH_Z;	// yellow high impedance
			selBlu = HIGH_PWM;	// blue driving positive
		  end
		  3'b001 : begin		// 2nd of blue high
			selGrn = HIGH_Z;	// green high impedance
			selYlw = LOW_PWM;	// yellow driving negative
			selBlu = HIGH_PWM;	// blue driving positive
		  end
		  default : begin
			 /// should not happen...turn off all coils if it does ///
			selGrn = HIGH_Z;
			selYlw = HIGH_Z;
			selBlu = HIGH_Z;
		  end
		endcase
	end else begin			// dynamic regenerative braking
	  selGrn = BRAKE;
	  selYlw = BRAKE;
	  selBlu = BRAKE;
	end
  end
  
endmodule
  
  