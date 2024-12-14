module fetch #(parameter ROI_DEPTH = 6, ROI_WIDTH = 6, POI_DEPTH = 4, POI_WIDTH = 4,
									 TOTAL_PIX = 4096, TOTAL_POI = 256) 
(
	input logic clk,
	input logic reset,
	input logic en,
	input logic [ROI_DEPTH + ROI_WIDTH - 1:0] w_addr_re,
	input logic [POI_DEPTH + POI_WIDTH - 1:0] POI_addr_re,
	input logic [4:0] w_row,
	output logic [4:0] w_row_wr,
	output logic [POI_DEPTH + POI_WIDTH - 1:0] POI_addr_wr,
	output logic [7:0] POI_data,
	output logic [7:0] w_row_data [31:0]
);

	// memory setup
	int core_mem [0:TOTAL_POI-1];
	int roi_mem [0:TOTAL_PIX-1];
	
	// SMALL SCALE
	initial begin
		// Use $readmemh to read integers from the file
		$readmemh("C:/Users/lucyc/OneDrive/school/Grad/Fall 2025/CSE548/project/mosaics_pynq/core_small.txt", core_mem); //"C:\Users\lucyc\OneDrive\school\Grad\Fall 2025\CSE548\project\smallScale\roi_small.txt"
		$readmemh("C:/Users/lucyc/OneDrive/school/Grad/Fall 2025/CSE548/project/mosaics_pynq/roi_small.txt", roi_mem);
	end
	
	// TEMP REGISTERS
	logic [7:0] POI_data_n;
	logic [7:0] w_row_data_n [31:0];
	
	// Calculate POI data
	always_comb begin
		POI_data_n = core_mem[POI_addr_re];
	end
	
	// Calculate row data
	always_comb begin
		for (int i = 0; i < 32; i++) begin
			w_row_data_n[i] = roi_mem[w_addr_re + i];
		end
	end
	
	// Update outputs on clock edge
	always_ff @(posedge clk) begin
		if (reset) begin
			POI_data <= 0;
//			w_row_data <= 0;
			w_row_wr <= 0;
			for (int i = 0; i < 32; i++) begin
				 w_row_data[i] <= 'd0;
			end
			POI_addr_wr <= 0;
		end else begin
			if (en) begin
				POI_data <= POI_data_n;
				w_row_data <= w_row_data_n;
				w_row_wr <= w_row;
				POI_addr_wr <= POI_addr_re;
			end
		end
	end
	
	
endmodule
