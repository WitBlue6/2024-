`timescale 1ns/1ps
module spi_slave(
	input          rst_n,        //复位信号，低有效
	input          cs_n,         //从设备片选使能信号
	input          sclk,         //SPI时钟,1kHz空闲时置低电平，
	input          mosi,        //从机从主机接收到的串行数据
    output         miso,        //从机要发送给主机的串行数据
	output  [7:0]  reg0_out,	 //内部寄存器0的值
	output  [7:0]  reg1_out,	 //内部寄存器1的值
	output  [7:0]  reg2_out,	 //内部寄存器2的值
	output  [7:0]  reg3_out 	 //内部寄存器3的值
);

//reg define
reg [6:0] address;  //主机写入的地址
reg [7:0] data_tmp;
reg [7:0] data_out = 8'd0;
reg [4:0] spi_cnt = 5'd0;
reg [7:0] reg0;
reg [7:0] reg1;
reg [7:0] reg2;
reg [7:0] reg3;
reg       read;
reg       MODE;  // 2: idle;   0: write register;   1: read register
reg       cs_n_d0;
reg       cs_n_d1;
reg       cs_n_d2;

//wire define
wire       write_start;

//对cs_n延时
always @(posedge sclk or negedge rst_n) begin
	if(!rst_n) begin
		cs_n_d0 <= 1;
		cs_n_d1 <= 1;
		cs_n_d2 <= 1;
	end
	else begin
		cs_n_d0 <= cs_n;
		cs_n_d1 <= cs_n_d0;
		cs_n_d2 <= cs_n_d1;
	end
end
//检测到cs_n上升沿，开始写寄存器
assign write_start = ~cs_n_d2 & cs_n_d1;

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

//spi
always @(posedge sclk or negedge rst_n) begin
	if(!rst_n) begin
		address <=7'b1111_111;
		data_tmp <= 8'd0;
		MODE <= 0;
	end
	else if(!cs_n) begin
		case(spi_cnt)
			4'd1:  MODE         <= mosi;
			4'd2:  address[6]   <= mosi;
			4'd3:  address[5]   <= mosi;
			4'd4:  address[4]   <= mosi;
			4'd5:  address[3]   <= mosi;
			4'd6:  address[2]   <= mosi;
			4'd7:  address[1]   <= mosi;
			4'd8:  address[0]   <= mosi;
			4'd9:  begin data_tmp[7]  <= mosi; read <= data_out[7]; end
			4'd10: begin data_tmp[6]  <= mosi; read <= data_out[6]; end
			4'd11: begin data_tmp[5]  <= mosi; read <= data_out[5]; end
			4'd12: begin data_tmp[4]  <= mosi; read <= data_out[4]; end
			4'd13: begin data_tmp[3]  <= mosi; read <= data_out[3]; end
			4'd14: begin data_tmp[2]  <= mosi; read <= data_out[2]; end
			4'd15: begin data_tmp[1]  <= mosi; read <= data_out[1]; end
			4'd16: begin data_tmp[0]  <= mosi; read <= data_out[0]; end
		endcase
	end
end

assign miso = read;

//reg write
always @(posedge sclk or negedge rst_n) begin
	if(!rst_n) begin
		reg0 <= 8'd0;
		reg1 <= 8'd0;
		reg2 <= 8'd0;
		reg3 <= 8'd0;
	end
	else if(write_start && MODE == 0) begin
		case(address)
			7'b000_0000: reg0 <= data_tmp;
			7'b000_0001: reg1 <= data_tmp;
			7'b000_0010: reg2 <= data_tmp;
			7'b000_0011: reg3 <= data_tmp;
		endcase
	end
end

assign reg0_out = reg0;
assign reg1_out = reg1;
assign reg2_out = reg2;
assign reg3_out = reg3;

//reg read
always @(posedge sclk or negedge rst_n) begin
	if(!rst_n) begin
		data_out <= 8'd0;
	end
	else if(spi_cnt == 5'd8 && MODE == 1) begin
		case({address[6:1], mosi})
			7'b000_0000: data_out <= reg0;
			7'b000_0001: data_out <= reg1;
			7'b000_0010: data_out <= reg2;
			7'b000_0011: data_out <= reg3;
		endcase
	end
end

endmodule