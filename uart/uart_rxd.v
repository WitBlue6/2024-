module uart_rxd( 	
	input				clk_40k,		//clock signal, 40kHz
	input				rst_n, 		//reset signal, active low
	input				bit_in,		//the input serial bit,
	output				dout_vld,		//the output valid signal， active high，the dout is valid when this signal is high.
	output	reg	[7:0]	dout		//received data, 8 bit width 
);

parameter SYS_CLK = 40_000;
parameter BPS = 1000;
parameter BPS_CNT = SYS_CLK / BPS;

reg		[3:0]	rx_cnt;
reg		[5:0]	sys_cnt;

reg				din_d1;
reg				din_d2;
reg				din_d3;
reg				rx_flag;

always @(posedge clk_40k or negedge rst_n)begin
	if(~rst_n) begin
		din_d1 <= 1;
		din_d2 <= 1;
		din_d3 <= 1;
	end
	else begin
		din_d1 <= bit_in;
		din_d2 <= din_d1;
		din_d3 <= din_d2;
	end
end

assign enflag = ~din_d2 & din_d3;

always @(posedge clk_40k or negedge rst_n)begin
	if(~rst_n)
		rx_flag <= 0;
	else if(enflag)
		rx_flag <= 1;
	else if(rx_cnt == 4'd9 && sys_cnt == BPS_CNT/2)
		rx_flag <= 0;
end

always @(posedge clk_40k or negedge rst_n)begin
	if(~rst_n)
		sys_cnt <= 0;
	else if(rx_flag)begin
		if(sys_cnt < BPS_CNT - 1)
			sys_cnt <= sys_cnt + 1;
		else	
			sys_cnt <= 0;
	end
	else
		sys_cnt <= 0;
end

always @(posedge clk_40k or negedge rst_n)begin
	if(~rst_n)
		rx_cnt <= 0;
	else if(rx_flag)begin
		if(sys_cnt == BPS_CNT - 1)
			rx_cnt <= rx_cnt + 1;
	end
	else
		rx_cnt <= 0;
end

always @(posedge clk_40k or negedge rst_n)begin
	if(~rst_n)
		dout <= 0;
	else if(rx_flag && sys_cnt == BPS_CNT/2)begin //only get once
		case(rx_cnt)
			4'd0: ;
			4'd1: dout[0] <= bit_in;	
			4'd2: dout[1] <= bit_in;
			4'd3: dout[2] <= bit_in;
			4'd4: dout[3] <= bit_in;
			4'd5: dout[4] <= bit_in;
			4'd6: dout[5] <= bit_in;
			4'd7: dout[6] <= bit_in;
			4'd8: dout[7] <= bit_in;
			4'd9: ;
		endcase
	end
end

assign dout_vld = (rx_cnt == 4'd9 && sys_cnt == BPS_CNT/2);

endmodule