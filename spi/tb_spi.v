`timescale 1ns/1ps
module tb_spi();

reg         clk;
reg [7:0]   data;
reg         en;
reg         rst_n;

initial begin
	clk = 0;
	data = 8'd0;
	en = 0;
	rst_n = 1;
	
	#50
	data = 8'b1001_0011;
	en = 1;
end


always #5 clk = ~clk;

spi_master u_spi(
	.clk_40k    (  clk  ),
	.rst_n      ( rst_n ),
	.data_in    (  data ),
	.send_start (  en   )
);

endmodule
