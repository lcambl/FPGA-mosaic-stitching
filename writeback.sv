module writeback #(parameter POI_DEPTH = 4, POI_WIDTH = 4) 
	(input logic clk,
	 input logic reset,
	 input logic en,
	 input logic [POI_DEPTH + POI_WIDTH - 1:0] POI_addr,
	 input logic [4:0] w_row,
	 input logic [7:0] residuals [31:0],
	 output logic done);
	 
	// TEMP REG
	logic done_n;
	logic [255:0] res_row; // temp row being populated
	logic [(5 + POI_DEPTH + POI_WIDTH - 1):0] seg_addr; 
	
	// MEMORY INIT - disabled for now because taking a long time
	logic [255:0] seg_mem [0:((1 << (5 + POI_DEPTH + POI_WIDTH))-1)]; // 2^15 addresses, 256-bit words
	
	// determine memory writing address
	assign seg_addr[4:0] = w_row;
	assign seg_addr[(5 + POI_DEPTH + POI_WIDTH - 1):5] = POI_addr;
	
	// copy residuals into data to be loaded into memory
	always_comb begin
		 res_row = '0; // Initialize res_row to avoid latches
		 for (int i = 0; i < 32; i++) begin
			  res_row[(255 - 8*i) -: 8] = residuals[i];
		 end
	end
	
	// logic to determine if mem is full 
	assign done_n = (POI_addr == 'd255 & w_row == 'd31);
	
	// Update outputs on clock edge
	always_ff @(posedge clk) begin
		if (reset) done <= 0;
		// don't re-init memory because can just be written over in next cycle 
		else begin
			if (en) begin
				seg_mem[seg_addr] <= res_row;
				done <= done_n;
			end
		end
	end

endmodule
