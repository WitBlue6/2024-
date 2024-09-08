module calc_top(
	input          clk,
	input          rst_n,
	input          cs_n,
	input          sclk,
	input          mosi,
	output         miso,
	output		   calc_done
);


//wire define
wire 			write_vld;
wire			read_en;
wire	  [6:0]	addr;
wire  	  [7:0]	data_w;
wire	  [7:0]	data_r;
//SPI通信接口
spi_slave u_spi(
	.rst_n		(rst_n),
	.cs_n		(cs_n),
	.sclk		(sclk),
	.mosi		(mosi),
	.miso		(miso),
	.write_vld	(write_vld),
	.read_en	(read_en),
	.addr		(addr),
	.data_w		(data_w),
	.data_r		(data_r)
);
//CALC计算接口
calc u_calc(
	.clk		(clk),
	.rst_n		(rst_n),
	.write_vld	(write_vld),
	.read_en	(read_en),
	.addr		(addr),
	.data_w		(data_w),
	.data_r		(data_r),
	.calc_done	(calc_done)
);

endmodule