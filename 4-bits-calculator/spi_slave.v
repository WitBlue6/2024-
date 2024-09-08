module spi_slave(
	input         		 rst_n,        //复位信号，低有效
	input         		 cs_n,         //从设备片选使能信号
	input         		 sclk,         //SPI时钟,1kHz空闲时置低电平，
	input         		 mosi,        //从机从主机接收到的串行数据
    output        		 miso,        //从机要发送给主机的串行数据
	output 		  		 write_vld,	  //写使能信号，高电平有效，spi_slave接收到有效写数据之后将该信号置1
	output		   		 read_en,		//读使能信号，高电平有效，spi_slave接收到读指令及有效读地址之后该信号置1
	output 	reg	  [6:0]  addr,
	output	reg	  [7:0]  data_w,		//外部通过spi_slave接口写入calc模块的数据，write_vld为高期间一直有效
	input		  [7:0]	 data_r
);

//reg define
reg [6:0] address;  //主机写入的地址
reg [7:0] data_tmp;
reg [7:0] data_out = 8'd0;
reg [4:0] spi_cnt = 5'd0;
reg [7:0] reg0;  //储存数据符
reg [7:0] reg1;	 //储存运算符
reg [7:0] reg7;  //0x07
reg [7:0] reg6;  //0x06
reg [7:0] reg5;  //0x05
reg [7:0] reg4;	 //0x04

reg       read;
reg 	  read_begin; //calc可以读
reg       write_begin;  //calc可以写
reg       MODE;  //0: write register;   1: read register


//spi_cnt计数
always @(negedge sclk or negedge rst_n) begin
	if(!rst_n)
		spi_cnt <= 5'd0;
	else if(!cs_n) begin
		if(spi_cnt < 5'd15) //等于15时，结束一轮spi通信
			spi_cnt <= spi_cnt + 5'd1;
		else
			spi_cnt <= 5'd0;
	end
end

//spi通信
always @(negedge sclk or negedge rst_n) begin
	if(!rst_n) begin
		address <= 7'd0;
		data_tmp <= 8'd0;
		MODE <= 1;
	end
	else if(!cs_n) begin
		case(spi_cnt)	//SPI的读写同时进行
			4'd0:  begin MODE         <= mosi; read <= 0; end
			4'd1:  begin address[6]   <= mosi; read <= 0; end
			4'd2:  begin address[5]   <= mosi; read <= 0; end
			4'd3:  begin address[4]   <= mosi; read <= 0; end
			4'd4:  begin address[3]   <= mosi; read <= 0; end
			4'd5:  begin address[2]   <= mosi; read <= 0; end
			4'd6:  begin address[1]   <= mosi; read <= 0; end
			4'd7:  begin address[0]   <= mosi; read <= data_r[7]; end
			4'd8:  begin data_tmp[7]  <= mosi; read <= data_r[6]; end
			4'd9:  begin data_tmp[6]  <= mosi; read <= data_r[5]; end
			4'd10: begin data_tmp[5]  <= mosi; read <= data_r[4]; end
			4'd11: begin data_tmp[4]  <= mosi; read <= data_r[3]; end
			4'd12: begin data_tmp[3]  <= mosi; read <= data_r[2]; end
			4'd13: begin data_tmp[2]  <= mosi; read <= data_r[1]; end
			4'd14: begin data_tmp[1]  <= mosi; read <= data_r[0]; end
			4'd15: begin data_tmp[0]  <= mosi; read <= 0; end
		endcase
	end
end

assign miso = read;

//addr output
always @(negedge sclk or negedge rst_n)begin
	if(!rst_n)
		addr <= 0;
	else if(spi_cnt == 5'd7)
		addr <= {address[7:1], mosi};  //读取完地址后，将地址输出
	else if(spi_cnt == 5'd0)	//新一轮SPI通信时addr重新置0
		addr <= 0;
end
//data_w
always @(negedge sclk or negedge rst_n)begin
	if(!rst_n)
		data_w <= 0;
	else if(spi_cnt == 15)
		data_w <= {data_tmp[7:1], mosi};  //完成一轮SPI通信后，输出data_w
	else if(spi_cnt == 0)	//新一轮重新置0
		data_w <= 0;
end

//reg write
always @(negedge sclk or negedge rst_n) begin
	if(!rst_n) begin
		reg0 <= 8'd0;
		reg1 <= 8'd0;
		reg4 <= 8'd0;
		reg5 <= 8'd0;
		reg6 <= 8'd0;
		reg7 <= 8'd0;
		write_begin <= 0;
	end
	else if(spi_cnt == 15 && MODE == 0) begin
		write_begin <= 1;  //写使能信号拉高
		case(address)   //读取完数据后，将数据存入对应地址的寄存器中
			7'h01: reg0 <= {data_tmp[7:1], mosi};
			7'h02: reg1 <= {data_tmp[7:1], mosi};
			7'h04: reg4 <= {data_tmp[7:1], mosi};
			7'h05: reg5 <= {data_tmp[7:1], mosi};
			7'h06: reg6 <= {data_tmp[7:1], mosi};
			7'h07: reg7 <= {data_tmp[7:1], mosi};
		endcase
	end
	else if(spi_cnt == 0)
		write_begin <= 0;
end

//reg read
always @(negedge sclk or negedge rst_n) begin
	if(!rst_n) begin
		data_out <= 8'd0;
		read_begin <= 0;
	end
	else if(spi_cnt == 5'd7 && MODE == 1) begin
		read_begin <= 1; //本实验中只需要输出data_r，故省略从寄存器中读地址
		/*case({address[6:1], mosi})
			7'h01: data_out <= reg0;
			7'h02: data_out <= reg1;
			7'h04: data_out <= reg2;
		endcase*/
	end
end

assign write_vld = write_begin;
assign read_en = read_begin;

endmodule