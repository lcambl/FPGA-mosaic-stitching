module mosaics_pynq(input logic CLK_IN,
						  input logic [1:0] sws_2bits_tri_i,
						  output logic [3:0] leds_4bits_tri_o);
						  
	// instantiate pipeline.sv
	parameter ROI_DEPTH = 6;
	parameter ROI_WIDTH = 6;
	parameter POI_DEPTH = 4;
	parameter POI_WIDTH = 4;
	pipeline #(ROI_DEPTH, ROI_WIDTH, POI_DEPTH, POI_WIDTH) pl (.clk(CLK_IN), .reset(sws_2bits_tri_i[0]), .status(leds_4bits_tri_o[0]));
						  
endmodule 

module mosaics_pynq_tb;

	logic CLK_IN;
	logic [1:0] sws_2bits_tri_i;
	logic [3:0] leds_4bits_tri_o;

	// Instantiate the module under test (MUT)
	mosaics_pynq dut (
	 .CLK_IN(CLK_IN),
	 .sws_2bits_tri_i(sws_2bits_tri_i),
	 .leds_4bits_tri_o(leds_4bits_tri_o)
	);	
	
	
//	 always begin
//        #0.5 CLK_IN = ~CLK_IN;  // Toggle every 0.5 ns for a 1 GHz clock (1 ns period)
//    end
	initial begin
        CLK_IN = 0; // Initialize clock to 0
        forever #4 CLK_IN = ~CLK_IN; // Toggle clock every 4 ns
    end
    initial begin
		  sws_2bits_tri_i[0] <= 1; @(posedge CLK_IN);
		                           @(posedge CLK_IN);
		                           @(posedge CLK_IN);
		                           @(posedge CLK_IN);
		                           @(posedge CLK_IN);
		                           @(posedge CLK_IN);
		  sws_2bits_tri_i[0] <= 0; @(posedge CLK_IN);
		                           @(posedge CLK_IN);
		  #1000000;
        $finish;
    end

endmodule 