module PWM11(clk,rst_n,duty,PWM_sig,PWM_synch);

  input clk,rst_n;		// clock and active low asynch reset
  input [10:0] duty;	// specifies duty cycle to motor drive
  output reg PWM_sig;
  output PWM_synch;
  
  wire set, reset;
  
  reg [10:0] cnt;
  

  
  ///////////////////////////
  // infer 11-bit counter //
  /////////////////////////
  always_ff @(posedge clk, negedge rst_n) 
    if (!rst_n)
	  cnt <= 11'h000;
	else
	  cnt <= cnt + 1;
	  
  assign set = ~|cnt;		// set at zero, but reset has priority
  assign reset = (cnt>=duty) ? 1'b1 : 1'b0;
  
  ////////////////////////////
  // infer PWM output flop //
  //////////////////////////
  always_ff @(posedge clk, negedge rst_n)
    if (!rst_n)
	  PWM_sig <= 1'b0;
	else if (reset)
	  PWM_sig <= 1'b0;
	else if (set)
	  PWM_sig <= 1'b1;
	  
  ////////////////////////////////////////////////////////////
  // PWM_synch is used to ensure commutation only switches //
  // during the deadband in which MOSFET gates are both   //
  // low.  Using 11'h001 ensures we are near beginning   //
  // of this dead time when commutation is switched     //
  ///////////////////////////////////////////////////////
  assign PWM_synch = (cnt==11'h003) ? 1'b1 : 1'b0;
  
endmodule
