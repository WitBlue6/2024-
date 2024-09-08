module uart_tx ( 	
	input				clk_40k,		//clock signal, 40kHz
	input				rst_n, 		//reset signal, active low
	input		[7:0]	din,			//the input data which will be sent by the UART module, 8 bit width
	input				send_start,	//the start enable signal, active high, the width is one clock period
	output	reg			bit_out		//the serial output data 
);

//parameter define
parameter  CLK_FREQ = 40000;             //系统时钟频率
parameter  UART_BPS = 1000;                 //串口波特率
localparam BPS_CNT  = CLK_FREQ/UART_BPS/2;    //为得到指定波特率，对系统时钟计数BPS_CNT/2次

//reg define
reg		[5:0]	clk_cnt = 0;
reg				clk_bps = 0;
reg		[3:0]	tx_cnt = 0;
reg				enflag = 0;
reg		[7:0]	data_in;

//uart enflag
always @(posedge clk_40k or negedge rst_n)begin
	if(!rst_n)
		enflag <= 0;
	else if(send_start) begin
		enflag <= 1;
		data_in <= din;
	end
	else if(tx_cnt == 4'd9 && clk_cnt == BPS_CNT - 1 && clk_bps == 0) //结束
		enflag <= 0;
end

//BPS clk 
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

//tx_cnt
always @(posedge clk_bps or negedge rst_n)begin
	if(!rst_n)
		tx_cnt <= 4'd0;
	else if(enflag && tx_cnt != 4'd9)
		tx_cnt <= tx_cnt + 4'd1;
	else if(tx_cnt == 4'd9)
		tx_cnt <= 4'd0;
end	

//uart_send
always @(posedge clk_bps or negedge rst_n)begin
	if(!rst_n)
		bit_out <= 1;
	else if(enflag) begin
		case(tx_cnt)
			4'd0:	bit_out <= 0; 			 //起始位
			4'd1:	bit_out <= data_in[0];
			4'd2:	bit_out <= data_in[1];
			4'd3:	bit_out <= data_in[2];
			4'd4:	bit_out <= data_in[3];
			4'd5:	bit_out <= data_in[4];
			4'd6:	bit_out <= data_in[5];
			4'd7:	bit_out <= data_in[6];
			4'd8:	bit_out <= data_in[7];
			4'd9:	bit_out <= 1;			//结束
		endcase
	end
	else
		bit_out <= 1;
end

endmodule
