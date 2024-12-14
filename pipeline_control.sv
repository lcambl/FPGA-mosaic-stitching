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
