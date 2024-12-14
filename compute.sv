module compute #(parameter POI_DEPTH = 4, POI_WIDTH = 4)
	(input logic clk,
	 input logic reset,
	 input logic en,
	 input logic [7:0] POI_data,
	 input logic [7:0] w_row_data [31:0],
	 input logic [4:0] w_row,
	 input logic [POI_DEPTH + POI_WIDTH - 1:0] POI_addr,
	 output logic [7:0] residuals [31:0],
	 output logic [4:0] w_row_wr,
	 output logic [POI_DEPTH + POI_WIDTH - 1:0] POI_addr_wr);
						  
	// TEMPORARY REGISTER
	logic [7:0] residuals_n [31:0];
	
	genvar i; // Loop variable for generate block
   generate
		for (i = 0; i < 32; i++) begin : subtractors
			subtractor_8bit u_sub (.A(POI_data),
						  .B(w_row_data[i]),
						  .result(residuals_n[i]));
		end
   endgenerate
	
	always_ff @(posedge clk) begin
		if (reset) begin
			w_row_wr <= 0;
			POI_addr_wr <= 0;
			for (int i = 0; i < 32; i++) begin
				 residuals[i] <= 'd0;
			end
		end else begin
			if (en) begin
				w_row_wr <= w_row;
				POI_addr_wr <= POI_addr;
				residuals <= residuals_n;
			end
		end
	end

endmodule