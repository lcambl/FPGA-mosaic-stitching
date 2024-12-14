module addr_gen #(parameter ROI_DEPTH = 6, ROI_WIDTH = 6, POI_DEPTH = 4, POI_WIDTH = 4,
									 ROI_ROWS = 64, ROI_COLS = 64, POI_ROWS = 16, POI_COLS = 16,
									 TOTAL_PIX = 4096, TOTAL_POI = 256)
(
	input logic clk,
	input logic reset,
	input logic en,
	input logic [4:0] w_row,
	input logic [POI_DEPTH-1:0] POI_row,
	input logic [POI_WIDTH-1:0] POI_col,
	output logic [4:0] w_row_next,
	output logic [POI_DEPTH-1:0] POI_row_next,
	output logic [POI_WIDTH-1:0] POI_col_next,
	output logic [ROI_DEPTH*2-1:0] w_addr_re,
	output logic [POI_DEPTH*2-1:0] POI_addr_re,
	output logic [4:0] w_row_wr
); 

	// temporary registers
	logic [4:0] w_row_next_n;
	logic [POI_DEPTH-1:0] POI_row_next_n;
	logic [POI_WIDTH-1:0] POI_col_next_n;
	logic [ROI_DEPTH*2-1:0] w_addr_re_n;
	logic [POI_DEPTH*2-1:0] POI_addr_re_n;
	
	// calculating next window row position
	always_comb begin
		if (w_row == 5'd31) w_row_next_n = 5'd0;
		else w_row_next_n = w_row + 1;
	end
	
	// calculating next POI coords
	always_comb begin
		if (w_row == 5'd31) begin
			if (POI_row == (POI_ROWS-1) && POI_col == (POI_COLS-1)) begin
				POI_row_next_n = 0;
				POI_col_next_n = 0; // Wrap to next column
			end else if (POI_row == (POI_ROWS-1)) begin
				POI_row_next_n = 0;
				POI_col_next_n = POI_col + 1;
			end else begin
				POI_row_next_n = POI_row + 1;
				POI_col_next_n = POI_col;
			end
		end else begin
			POI_row_next_n = POI_row;
			POI_col_next_n = POI_col;
		end
	end	
	
	// calculating addresses
	always_comb begin
		w_addr_re_n = (POI_row + w_row) * 64 + POI_col;
		POI_addr_re_n = POI_row * 16 + POI_col;
	end	
	
	// set outputs on clock edge
	always_ff @(posedge clk) begin
		if (reset) begin
			w_row_next <= 0;
			POI_row_next <= 0;
			POI_col_next <= 0;
			w_addr_re <= 0;
			POI_addr_re <= 0;
			w_row_wr <= 0;
		end else begin
			if (en) begin
				w_row_next <= w_row_next_n;
				POI_row_next <= POI_row_next_n;
				POI_col_next <= POI_col_next_n;
				w_addr_re <= w_addr_re_n;
				POI_addr_re <= POI_addr_re_n;
				w_row_wr <= w_row;
			end
		end
	end

endmodule 