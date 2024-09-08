module uart_rx ( 	
	input				clk_40k,		//clock signal, 40kHz
	input				rst_n, 		//reset signal, active low
	input				bit_in,		//the input serial bit,
	output	reg			dout_vld,		//the output valid signal， active high，the dout is valid when this signal is high.
	output	reg	[7:0]	dout		//received data, 8 bit width 
);

//parameter define
parameter  CLK_FREQ = 40000;             //系统时钟频率
parameter  UART_BPS = 1000;                 //串口波特率
localparam BPS_CNT  = CLK_FREQ/UART_BPS/2;    //为得到指定波特率，对系统时钟计数BPS_CNT/2次

//reg define
reg		[5:0]	clk_cnt = 0;
reg				clk_bps = 0;
reg		[3:0]	rx_cnt = 0;
reg				enflag = 0;

//BPS clock
always @(posedge clk_40k or negedge rst_n)begin
	if(!rst_n) begin
		clk_bps <= 0;
		clk_cnt <= 0;
	end
	else begin
		clk_cnt <= clk_cnt + 1;
		if(clk_cnt == BPS_CNT - 1) begin
			clk_cnt <= 0;
			clk_bps <= ~clk_bps;
		end
	end
end

//uart_rx enflag
always @(negedge clk_bps or negedge rst_n)begin
	if(!rst_n)
		enflag <= 0;
	else if(bit_in == 0)
		enflag <= 1;
	else if(rx_cnt == 4'd9)
		enflag <= 0;
end

//rx counter
always @(posedge clk_bps or negedge rst_n)begin
	if(!rst_n)
		rx_cnt <= 0;
	else if(enflag && rx_cnt != 4'd9)
		rx_cnt <= rx_cnt + 4'd1;
	else if(rx_cnt == 4'd9)
		rx_cnt <= 0;
end

//data output
always @(negedge clk_bps or negedge rst_n)begin
	if(!rst_n)
		dout <= 8'd0;
	else begin
		case(rx_cnt)
			4'd1:	dout[0] <= bit_in;
			4'd2:	dout[1] <= bit_in;
			4'd3:	dout[2] <= bit_in;
			4'd4:	dout[3] <= bit_in;
			4'd5:	dout[4] <= bit_in;
			4'd6:	dout[5] <= bit_in;
			4'd7:	dout[6] <= bit_in;
			4'd8:	dout[7] <= bit_in;
		endcase
	end
end	
//data output valid
always @(negedge clk_bps or negedge rst_n)begin
	if(!rst_n)
		dout_vld <= 0;
	else if(rx_cnt == 4'd9)
		dout_vld <= 1;
	else if(rx_cnt == 4'd0)
		dout_vld <= 0;
end

endmodule