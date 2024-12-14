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
