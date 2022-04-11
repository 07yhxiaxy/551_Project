module nonoverlap(clk,rst_n,highIn,lowIn,highOut,lowOut);

  input clk;					// 50MHz clock
  input rst_n;					// active low reset
  input highIn,lowIn;			// gate control inputs
  output reg highOut,lowOut;	// gate control outputs (ensured)
  
  reg [1:0] last_in;	// captures last inputs for change detection
  reg [4:0] dead_cnt;	// counter for dead time
  
  wire changed;			// inputs changed
  wire dead_over;		// dead_time over
  
  ////////////////////////////////////////////////////////
  // Flop current inputs to implement change detection //
  //////////////////////////////////////////////////////
  always_ff @(posedge clk)
    last_in <= {highIn,lowIn};

  /////////////////////////////////
  // Implement change detection //
  ///////////////////////////////
  assign changed = (last_in=={highIn,lowIn}) ? 1'b0 : 1'b1;
  
  
  ///////////////////////////////////////
  // Implement counter that will give // 
  // 32-cycles of dead time          //
  ////////////////////////////////////
  always_ff @(posedge clk, negedge rst_n)
    if (!rst_n)
	  dead_cnt <= 5'b000000;
	else if (changed)
	  dead_cnt <= 5'b000000;
	else if (!dead_over)
	  dead_cnt <= dead_cnt + 1;
	  
  /// dead time over when dead_cnt gets full ///
  assign dead_over = &dead_cnt;
  
  always_ff @(posedge clk, negedge rst_n)
    if (!rst_n) begin
	  highOut <= 1'b0;
	  lowOut <= 1'b0;
	end else if (changed | ~dead_over) begin	// clear on changed
	  highOut <= 1'b0;
	  lowOut <= 1'b0;
	end else begin
	  highOut <= highIn;
	  lowOut <= lowIn;
	end
	  
endmodule