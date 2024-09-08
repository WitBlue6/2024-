`timescale 1ns/1ps
module tb_fir();

reg 			clk;
reg 			rst_n;
reg 	[8:0]	data;
wire	[8:0]	data_out;

reg [8:0] samp[0:999];  //sample.txt数据
reg [9:0] n;

initial begin
	rst_n = 0;
	clk = 0;
	data = 0;
	$readmemh("sample.txt", samp);
	#100
	@(posedge clk)
	rst_n = 1;
	repeat(10) begin
		for(n=0; n<= 999; n=n+1) begin
			@(posedge clk) begin
				data = samp[n];
			end
		end
	end
	
	repeat(10) begin
		@(posedge clk);
	end
	$stop();
end

always #10 clk = ~clk;
fir u_fir(
	.clk_100k	(clk),
	.rst_n		(rst_n),
	.samp_in	(data),
	.fir_out	(data_out)
);
endmodule