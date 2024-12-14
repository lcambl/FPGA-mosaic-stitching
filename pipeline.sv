module pipeline #(parameter ROI_DEPTH = 6, ROI_WIDTH = 6, POI_DEPTH = 4, POI_WIDTH = 4)(
	input logic clk,
	input logic reset,
	output logic status
);
	
	// PARAMETER CREATION
	parameter ROI_ROWS = 1 << ROI_DEPTH;
	parameter ROI_COLS = 1 << ROI_WIDTH;
	parameter POI_ROWS = 1 << POI_DEPTH;
	parameter POI_COLS = 1 << POI_WIDTH;
	parameter TOTAL_POI = POI_ROWS * POI_COLS;
	parameter TOTAL_PIX = ROI_ROWS * ROI_COLS;
	
	// TEMPORARY REGISTERS
	logic en, done;
	logic [4:0] w_row, w_row_next, w_row_wr_1, w_row_wr_2, w_row_wr_3; // wr_1 output of stage 1, wr_2 output of stage 2
	logic [POI_DEPTH-1:0] POI_row, POI_row_next;
	logic [POI_WIDTH-1:0] POI_col, POI_col_next;
	logic [ROI_DEPTH + ROI_WIDTH - 1:0] w_addr_re; // output of stage 1 and input to stage 2
	logic [POI_DEPTH + POI_WIDTH - 1:0] POI_addr_re, POI_addr_wr_2, POI_addr_wr_3; // output of stage 1, output of stage 2, output of stage 3
	logic [7:0] POI_data;
	logic [7:0] w_row_data [31:0];
	logic [7:0] residuals [31:0];
	
	// PIPELINE CONTROL
	pipeline_control pc (.clk(clk), .reset(reset), .done(done), .en(en));
	
	// STAGE 1 - ADDR GEN
	// update inputs to stage 1
	always_ff @(posedge clk) begin
		if (reset) begin
			POI_row <= 0;
			POI_col <= 0;
			w_row <= 0;
		end else begin
			if (en) begin
				POI_row <= POI_row_next;
				POI_col <= POI_col_next;
				w_row <= w_row_next;
			end
		end
	end
	
	addr_gen #(ROI_DEPTH, ROI_WIDTH, POI_DEPTH, POI_WIDTH, ROI_ROWS, ROI_COLS, POI_ROWS, POI_COLS, TOTAL_PIX, TOTAL_POI)
				ag (.clk(clk), .reset(reset), .en(en), .w_row(w_row), .POI_row(POI_row), .POI_col(POI_col),
					 .w_row_next(w_row_next), .POI_row_next(POI_row_next), .POI_col_next(POI_col_next), .w_addr_re(w_addr_re),
					 .POI_addr_re(POI_addr_re), .w_row_wr(w_row_wr_1));
	
	// STAGE 2 - FETCH
	fetch #(ROI_DEPTH, ROI_WIDTH, POI_DEPTH, POI_WIDTH, TOTAL_PIX, TOTAL_POI) 
			f (.clk(clk), .reset(reset), .en(en), .w_addr_re(w_addr_re), .POI_addr_re(POI_addr_re), .w_row(w_row_wr_1),
				.w_row_wr(w_row_wr_2), .POI_addr_wr(POI_addr_wr_2), .POI_data(POI_data), .w_row_data(w_row_data));
	
	// STAGE 3 - COMPUTE
	compute #(POI_DEPTH, POI_WIDTH)
		c (.clk(clk), .reset(reset), .en(en), .POI_data(POI_data), .w_row_data(w_row_data), .w_row(w_row_wr_2), .POI_addr(POI_addr_wr_2),
			.residuals(residuals), .w_row_wr(w_row_wr_3), .POI_addr_wr(POI_addr_wr_3));
	
	// STAGE 4 - WRITEBACK
	writeback #(POI_DEPTH, POI_WIDTH) 
		wb (.clk(clk),
			 .reset(reset),
			 .en(en),
			 .POI_addr(POI_addr_wr_3),
			 .w_row(w_row_wr_3),
			 .residuals(residuals),
			 .done(done));
			 
	assign status = done;

endmodule
