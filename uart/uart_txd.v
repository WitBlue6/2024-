module uart_txd(
	input				clk_40k,		//clock signal, 40kHz
	input				rst_n, 		//reset signal, active low
	input		[7:0]	din,			//the input data which will be sent by the UART module, 8 bit width
	input				send_start,	//the start enable signal, active high, the width is one clock period
	output	reg			bit_out		//the serial output data 
);

parameter SYS_CLK = 40_000;
parameter BPS = 1000;
parameter BPS_CNT = SYS_CLK / BPS;

reg 	[3:0]		tx_cnt;
reg 	[5:0]		sys_cnt;

reg		[7:0]		data_in;

reg					din_d1;
reg					din_d2;
reg					din_d3;
reg					tx_flag;

always @(posedge clk_40k or negedge rst_n)begin
	if(~rst_n)begin
		din_d1 <= 0;
		din_d2 <= 0;
		din_d3 <= 0;
	end
	else begin
		din_d1 <= send_start;
		din_d2 <= din_d1;
		din_d3 <= din_d2;
	end
end			

assign enflag = din_d2 & ~din_d3;

always @(posedge clk_40k or negedge rst_n)begin
	if(~rst_n)
		tx_flag <= 0;
	else if(enflag)
		tx_flag <= 1;
	else if(tx_cnt == 4'd9 && sys_cnt == BPS_CNT/2)
		tx_flag <= 0;
end

always @(posedge clk_40k or negedge rst_n)begin
	if(~rst_n)
		data_in <= 8'd0;
	else if(enflag)
		data_in <= din;
end

always @(posedge clk_40k or negedge rst_n)begin
	if(~rst_n)
		sys_cnt <= 6'd0;
	else if(tx_flag)begin
		if(sys_cnt < BPS_CNT - 1)
			sys_cnt <= sys_cnt + 6'd1;
		else
			sys_cnt <= 6'd0;
	end
	else
		sys_cnt <= 6'd0;
end

always @(posedge clk_40k or negedge rst_n)begin
	if(~rst_n)
		tx_cnt <= 4'd0;
	else if(tx_flag)begin
		if(sys_cnt == BPS_CNT - 1)
			tx_cnt <= tx_cnt + 4'd1;
	end
	else
		tx_cnt <= 4'd0;
end

always @(posedge clk_40k or negedge rst_n)begin
	if(~rst_n)
		bit_out <= 1;
	else if(tx_flag)begin
		case(tx_cnt)
			4'd0:	bit_out <= 0;
			4'd1:	bit_out <= data_in[0];
			4'd2:	bit_out <= data_in[1];
			4'd3:	bit_out <= data_in[2];
			4'd4:	bit_out <= data_in[3];
			4'd5:	bit_out <= data_in[4];
			4'd6:	bit_out <= data_in[5];
			4'd7:	bit_out <= data_in[6];
			4'd8:	bit_out <= data_in[7];
			4'd9:	bit_out <= 1;
		endcase
	end
	else 
		bit_out <= 1;
end

endmodule