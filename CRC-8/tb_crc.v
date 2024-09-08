`timescale 1ns/1ps
module tb_crc();

reg clk;
wire rst_n;
wire [63:0] din;
wire start;
wire crc_vld;
wire [7:0] crc_o;

reg [63:0] data;
reg en;
reg rst;

initial begin
	clk = 0;
	en = 0;
	rst = 0;
	#500
	rst = 1;
	data = 64'hFFFF_FFFF_FFFF_FFFF;
	en = 1;
	#50000
	en = 0;
	rst = 0;
	#500
	rst = 1;
	data = 64'hABCD_ABCD_ABCD_ABCD;
	en = 1;
	#50000
	en = 0;
	rst = 0;
	#500
	rst = 1;
	data = 64'hAAAA_BBBB_CCCC_DDDD;
	en = 1;
	#50000
	en = 0;
	rst = 0;
end

//assign din = 64'hFFFF_FFFF_FFFF_FFFF;
assign din = data;
assign start = en;
assign rst_n = rst;
always #10 clk = ~clk;



crc_8 u_crc8(
	.clk(clk),
	.rst_n(rst_n),
	.din(din),
	.crc_start(en),
	.crc_vld(crc_vld),
	.crc_o(crc_o)
);

endmodule