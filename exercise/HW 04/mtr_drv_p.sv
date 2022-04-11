module mtr_drv(clk,rst_n,duty,selGrn,selYlw,
               selBlu,highGrn,lowGrn,highYlw,
			   lowYlw,highBlu,lowBlu,PWM_synch);

  input clk;								// 50MHz clock
  input rst_n;								// active low reset
  input [10:0] duty;						// duty cycle to drive coil at
  input [1:0] selGrn,selYlw,selBlu;			// selects gate drive routing
  output highGrn,highYlw,highBlu;			// to high side FET
  output lowGrn,lowYlw,lowBlu;				// to low side FET
  output PWM_synch;
  
  localparam HIGH_Z = 2'b00;
  localparam LOW_PWM = 2'b01;
  localparam HIGH_PWM = 2'b10;
  
  wire PWM_sig;								// route to FET gate
  wire highGrn_i,lowGrn_i;					// internal versions of power FET
  wire highYlw_i,lowYlw_i;					// gate controls
  wire highBlu_i,lowBlu_i;
	
  ///////////////////////
  // Instantiate PWMs //
  /////////////////////
  PWM high_pwm(.clk(clk),.rst_n(rst_n),.duty(duty),.PWM_sig(PWM_sig),.PWM_synch(PWM_synch));
  
  //////////////////////////////////////////////////////////////
  // Create high/low FET gate drive signals based on selects //
  ////////////////////////////////////////////////////////////
  assign highGrn_i = (selGrn==HIGH_Z) ? 1'b0 :
                     (selGrn==LOW_PWM) ? ~PWM_sig :
					 (selGrn==HIGH_PWM) ? PWM_sig :
					 1'b0;
					 
  assign lowGrn_i = (selGrn==HIGH_Z) ? 1'b0 :
                    (selGrn==LOW_PWM) ? PWM_sig :
					(selGrn==HIGH_PWM) ? ~PWM_sig :
					PWM_sig;
					
  assign highYlw_i = (selYlw==HIGH_Z) ? 1'b0 :
                     (selYlw==LOW_PWM) ? ~PWM_sig :
					 (selYlw==HIGH_PWM) ? PWM_sig :
					 1'b0;
					 
  assign lowYlw_i = (selYlw==HIGH_Z) ? 1'b0 :
                    (selYlw==LOW_PWM) ? PWM_sig :
					(selYlw==HIGH_PWM) ? ~PWM_sig :
					PWM_sig;
					
  assign highBlu_i = (selBlu==HIGH_Z) ? 1'b0 :
                     (selBlu==LOW_PWM) ? ~PWM_sig :
					 (selBlu==HIGH_PWM) ? PWM_sig :
					 1'b0;
					 
  assign lowBlu_i = (selBlu==HIGH_Z) ? 1'b0 :
                    (selBlu==LOW_PWM) ? PWM_sig :
					(selBlu==HIGH_PWM) ? ~PWM_sig :
					PWM_sig;
  
  //////////////////////////////////////////////////////////////
  // Ensure sufficient non-overlap of high/low drive signals //
  ////////////////////////////////////////////////////////////
  nonoverlap iGRNno(.clk(clk),.rst_n(rst_n),.highIn(highGrn_i),
                    .lowIn(lowGrn_i),.highOut(highGrn),.lowOut(lowGrn));
  nonoverlap iYLWno(.clk(clk),.rst_n(rst_n),.highIn(highYlw_i),
                    .lowIn(lowYlw_i),.highOut(highYlw),.lowOut(lowYlw));
  nonoverlap iBLUno(.clk(clk),.rst_n(rst_n),.highIn(highBlu_i),
                    .lowIn(lowBlu_i),.highOut(highBlu),.lowOut(lowBlu));					
endmodule

  