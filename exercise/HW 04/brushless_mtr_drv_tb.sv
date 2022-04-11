module brushless_mtr_drv_tb();

  /// stimulus declared as type reg;
  logic clk, rst_n;
  reg [11:0] drv_mag;
  reg [2:0] hallStim;	/// {hallGrn,hallYlw,hallBlu} ///
  reg brake_n;
  
  /// internal signals connecting brushless to mtr_drv ///
  wire PWM_synch;
  wire [10:0] duty;
  wire [1:0] selGrn,selYlw,selBlu;
  
  /// mtr_drv output signals being monitored ///
  wire highGrn,lowGrn;
  wire highYlw,lowYlw;
  wire highBlu,lowBlu;
  
  ////////////////////////////////
  // Instantiate brushless DUT //
  //////////////////////////////
  brushless DUT1(.clk(clk),.rst_n(rst_n),.drv_mag(drv_mag),
                 .PWM_synch(PWM_synch),.hallGrn(hallStim[2]),
				 .hallYlw(hallStim[1]),.hallBlu(hallStim[0]),
				 .brake_n(brake_n),.duty(duty),.selGrn(selGrn),
				 .selYlw(selYlw),.selBlu(selBlu));	

  //////////////////////////////
  // Instantiate mtr_drv DUT //
  ////////////////////////////	
  mtr_drv DUT2(.clk(clk),.rst_n(rst_n),.duty(duty),.selGrn(selGrn),
               .selYlw(selYlw),.selBlu(selBlu),.highGrn(highGrn),
			   .lowGrn(lowGrn),.highYlw(highYlw),.lowYlw(lowYlw),
			   .highBlu(highBlu),.lowBlu(lowBlu),.PWM_synch(PWM_synch));

  // Brushless signals
  logic hallGrn, hallYlw, hallBlu;

  // assign hallStim = {hallGrn, hallYlw, hallBlu};
  logic pwm = DUT2.pwm_sig;

  initial begin
    clk = 0;
    // << initialize all input signals to brushless >>
    drv_mag = 0;
    hallGrn = 0;
    hallYlw = 0;
    hallBlu = 0;
    brake_n = 1;
    // << start with hallStim at 3'b101 (same as in table) >>
    hallStim = 3'b100;
    // << assert rst_n >>
    rst_n = 0;
    // << wait till negedge clock and deassert rst_n >>
    @(negedge clk) begin
      rst_n = 1;
    end
    // << easiest to change hallStim at occurances of PWM_synch >>
    @(posedge PWM_synch) begin
      if (hallStim != 0) begin
        hallStim = hallStim+1;
        #5;
      end
      else
      $stop();
    end
    // << observe each output of mtr_drv (highGrn,lowGrn, ...) >>
    // << check output of all six valid hall states >>
    if (hallStim == 3'b101) begin
      if ((highGrn != pwm) | (lowGrn != ~pwm) | (highYlw != ~pwm) | (lowYlw != pwm) | highBlu|lowBlu) begin
        $display("error at 101 state");
        $stop();
      end
    end
    if (hallStim == 3'b100) begin
      if ((highGrn != pwm) | (lowGrn != ~pwm) | (highBlu != ~pwm) | (lowBlu != pwm) | highYlw|lowYlw) begin
        $display("error at 100 state");
        $stop();
      end
    end
    if (hallStim == 3'b110) begin
      if ((highBlu != ~pwm) | (lowBlu != pwm) | (highYlw != pwm) | (lowYlw != ~pwm) | hallGrn|lowGrn) begin
        $display("error at 101 state");
        $stop();
      end
    end
    if (hallStim == 3'b010) begin
      if ((highGrn != ~pwm) | (lowGrn != pwm) | (highYlw != pwm) | (lowYlw != ~pwm) | highBlu|lowBlu) begin
        $display("error at 101 state");
        $stop();
      end
    end
    if (hallStim == 3'b011) begin
      if ((highGrn != ~pwm) | (lowGrn != pwm) | (highBlu != pwm) | (lowBlu != ~pwm) | highYlw|lowYlw) begin
        $display("error at 101 state");
        $stop();
      end
    end
    if (hallStim == 3'b001) begin
      if ((highBlu != pwm) | (lowBlu != ~pwm) | (highYlw != ~pwm) | (lowYlw != pwm) | highGrn|lowGrn) begin
        $display("error at 101 state");
        $stop();
      end
    end
    // << check output of an invalid hall state >>
    if (hallStim == 3'b000 | hallStim == 3'b111) begin
      if (highGrn | lowGrn | highYlw | lowYlw | highBlu | lowBlu) begin
        $display("error at invalid state");
        $stop();
      end
    end
    // << check output when brake_n is high >>
    if (~brake_n) begin
      if (highBlu | highYlw | highGrn) begin
        $display("error at regen brake state");
        $stop();
      end
    end
    // << these can be manual checks (don't self check) >>
    // << when done with all that move on to PartII using hub_wheel_model.sv >>
    $stop();
	
  end

  always
  #5 clk = ~clk;  
				 
endmodule