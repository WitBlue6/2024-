`timescale 1ns/1ps
module tb_uart();

reg			clk_40k;
reg			rst_n;
reg	 [7:0]	din;
wire [7:0]	dout;
reg			en;
wire		bit_out;
wire		dout_vld;
reg			pass;

initial begin
	clk_40k = 0;
	rst_n = 0;
	en = 0;
	#12500
	rst_n = 1;
	#50000
	repeat(20) begin
		@(posedge clk_40k)
		en = 1;
		din = $random % 256;
		@(posedge clk_40k) 
		en = 0;
		@(posedge dout_vld)

		pass = (din == dout);
	end
	$stop();
end


always #12500 clk_40k = ~clk_40k;

uart_txd u_uart_txd(
	.clk_40k	(	clk_40k	),
	.rst_n		(	rst_n	),
	.din		(	din		),
	.send_start	(	en 		),
	.bit_out	(	bit_out	)
);

uart_rxd u_uart_rxd(
	.clk_40k	(	clk_40k	),
	.rst_n		(	rst_n	),
	.bit_in		(	bit_out	),
	.dout_vld	(	dout_vld),
	.dout		(	dout	)
);

endmodule