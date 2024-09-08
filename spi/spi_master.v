`timescale 1ns/1ps
module spi_master(
	input          clk_40k,
	input          rst_n,
	input  [7:0]   data_in,
	input          send_start,
	output  reg [7:0]   data_out,
	output  reg       data_out_vld,
	output  reg    cs_n,
	output  reg    sclk,
	input          miso,
	output         mosi
);

//reg define
reg  [4:0]  spi_cnt = 5'd0;
reg  [5:0]  clk_cnt = 6'd0;
reg  [7:0]  data_send;
reg  [6:0]  address;
reg  [2:0]  reg_cnt = 3'd0;  //系统计数 0~3：向从机寄存器0~3发送数据， 4：接收从机寄存器3的数据
reg         write;
reg			vld_flag = 0;
//wire define
wire  [7:0]  reg0_out;
wire  [7:0]  reg1_out;
wire  [7:0]  reg2_out;
wire  [7:0]  reg3_out;

//如果send_start置高，开始向四个寄存器写入，并从寄存器3读取
always @(posedge sclk or negedge rst_n) begin
	if(!rst_n) 
		cs_n <= 1;
	else if((send_start && spi_cnt != 5'd16) || (spi_cnt == 5'd0 && reg_cnt != 3'd4 && reg_cnt != 3'd0)) //每次为0重新开始选通
		cs_n <= 0;
	else if(spi_cnt == 5'd16)  
		cs_n <= 1;
	else 
		cs_n <= cs_n;
end

//data_out_vld信号
always @(posedge clk_40k or negedge rst_n) begin
	if(!rst_n) 
		data_out_vld <= 0;
	else if(spi_cnt == 5'd1 && reg_cnt == 3'd5) begin//数据写入并读取结束
		if(vld_flag == 0) //只持续clk_40k
			data_out_vld <= 1;
		else
			data_out_vld <= 0;
	end
	else
		data_out_vld <= 0;
end

//vld_flag
always @(posedge clk_40k or negedge rst_n) begin
	if(!rst_n)
		vld_flag <= 0;
	else if(data_out_vld == 1)
		vld_flag <= 1;
end

//待写入从机的data_send数据
always @(posedge sclk or negedge rst_n) begin
	if(!rst_n)
		data_send <= 8'd0;
	else if(send_start || !cs_n) begin
		if(reg_cnt == 3'd0 && spi_cnt == 5'd0)
			data_send <= data_in;
		else if(reg_cnt != 3'd4 && spi_cnt == 5'd15) //即将写完一个寄存器，向下一个寄存器写入移位数据
			data_send <= {data_send[1:0], data_send[7:2]};
		else if(reg_cnt == 3'd4)//进入读模式
			data_send <= 8'd0;
	end
end

//address数据
always @(posedge clk_40k or negedge rst_n) begin
	if(!rst_n)
		address <= 7'd0;
	else if(send_start || !cs_n) begin
		case(reg_cnt)
			3'd0: address <= 7'b000_0000;
			3'd1: address <= 7'b000_0001;
			3'd2: address <= 7'b000_0010;
			3'd3: address <= 7'b000_0011;
			3'd4: address <= 7'b000_0011;  //读取寄存器3
		endcase
	end
end

//如果cs_n置低，开始进行SPI的读写逻辑
always @(posedge clk_40k or negedge rst_n) begin  //sclk时钟1kHz
	if(!rst_n)
		sclk <= 0;
	else if(send_start) begin
		if(clk_cnt == 6'd39)
			sclk <= ~sclk;
	end
	else
		sclk <= 0;
end

//clk_cnt计数
always @(posedge clk_40k or negedge rst_n) begin
	if(!rst_n)
		clk_cnt <= 6'd0;
	else if(clk_cnt < 6'd39)
		clk_cnt <= clk_cnt + 6'd1;
	else
		clk_cnt <= 6'd0;
end

//spi_cnt计数
always @(posedge sclk or negedge rst_n) begin  
	if(!rst_n)
		spi_cnt <= 5'd0;
	else if(!cs_n) begin
		if(spi_cnt < 5'd16)
			spi_cnt <= spi_cnt + 5'd1;
		else
			spi_cnt <= 5'd0;
	end
end

//reg_cnt计数
always @(posedge sclk or negedge rst_n) begin
	if(!rst_n)
		reg_cnt <= 3'd0;
	else if(!cs_n && spi_cnt == 5'd16) begin
		if(reg_cnt < 3'd5)
			reg_cnt <= reg_cnt + 3'd1;
		else
			reg_cnt <= reg_cnt;  //最后一直为5
	end
end

//spi write
always @(posedge sclk or negedge rst_n) begin
	if(!rst_n)
		write <= 0;
	else if(!cs_n) begin
		case(spi_cnt)
			4'd0:  begin if(reg_cnt <= 3'd3) write <= 0;  //写三次
						 else  	write <= 1;  //读一次
				   end
			4'd1:  write <= address[6];
			4'd2:  write <= address[5];
			4'd3:  write <= address[4];
			4'd4:  write <= address[3];
			4'd5:  write <= address[2];
			4'd6:  write <= address[1];
			4'd7:  write <= address[0];
			4'd8:  write <= data_send[7];
			4'd9:  write <= data_send[6];
			4'd10: write <= data_send[5];
			4'd11: write <= data_send[4];
			4'd12: write <= data_send[3];
			4'd13: write <= data_send[2];
			4'd14: write <= data_send[1];
			4'd15: write <= data_send[0];
			4'd16: ; //等待reg传入slave
		endcase
	end
end

//spi read
always @(posedge sclk or negedge rst_n) begin
	if(!rst_n) begin
		data_out <= 8'd0;
	end
	else if(!cs_n) begin
		case(spi_cnt)
			4'd0:  data_out[1] <= miso;
			4'd1:  data_out[0] <= miso;
			4'd2:  ;
			4'd3:  ;
			4'd4:  ;
			4'd5:  ;
			4'd6:  ;
			4'd7:  ;
			4'd8:  ;
			4'd9:  ;
			4'd10: data_out[7] <= miso;
			4'd11: data_out[6] <= miso;
			4'd12: data_out[5] <= miso;
			4'd13: data_out[4] <= miso;
			4'd14: data_out[3] <= miso;
			4'd15: data_out[2] <= miso;
			4'd16: ;
		endcase
	end
end

assign mosi = write;

spi_slave u_slave(
	//input
	.rst_n    (   rst_n  ),
	.cs_n     (   cs_n   ),
	.sclk     (   sclk   ),
	.mosi     (   mosi   ),
	//output
	.miso     (   miso   ),
	.reg0_out ( reg0_out ),
	.reg1_out ( reg1_out ),
	.reg2_out ( reg2_out ),
	.reg3_out ( reg3_out )
);
endmodule