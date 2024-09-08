module clock_div(
	input			clk_in,
	input			rst_n,
	output	reg		clk_out
);

reg		[23:0]		clk_cnt;

always @(posedge clk_in or negedge rst_n)begin
	if(~rst_n)
		clk_cnt <= 23'd0;
	else if(clk_cnt == 24'd2499)
		clk_cnt <= 23'd0;
	else
		clk_cnt <= clk_cnt + 23'd1;
end

always @(posedge clk_in or negedge rst_n)begin
	if(~rst_n)
		clk_out <= 1'b0;
	else if(clk_cnt == 24'd2499)
		clk_out <= ~clk_out;
end	

endmodule