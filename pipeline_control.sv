module pipeline_control (input logic clk,
								 input logic reset,
								 input logic done,
								 output logic en);
								 
	always_ff @(posedge clk) begin
		if (reset) en <= 1;
		else begin
			if (done) en <= 0;
		end
	end

endmodule


module pipeline_control_tb;
	logic reset, clk, done, en;

	// Instantiate the module under test (MUT)
	pipeline_control mut (.clk(clk), .reset(reset), .done(done), .en(en));	
	
	
	 always begin
        #0.5 clk = ~clk;  // Toggle every 0.5 ns for a 1 GHz clock (1 ns period)
    end
	 
    // Instantiate the design under test (DUT) here
    initial begin
        // Initialize the clock
        clk = 0;

        // Other testbench initialization
		  reset <= 1; done <= 0; @(posedge clk);
		  reset <= 0; @(posedge clk);
						  @(posedge clk);
						  @(posedge clk);
						  @(posedge clk);
						  @(posedge clk);
						  @(posedge clk);
						  @(posedge clk);
						  @(posedge clk);
						  @(posedge clk);
						  @(posedge clk);
			done <= 1; @(posedge clk);
			done <= 0; @(posedge clk);
						  @(posedge clk);
						  @(posedge clk);
						  @(posedge clk);
						  @(posedge clk);
						  @(posedge clk);
						  @(posedge clk);

        $finish;
    end
endmodule
