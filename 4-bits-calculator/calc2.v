module calc(
	input 				sclk,
	input 				clk,
	input 				rst_n,
	input 				write_vld,
	input 				read_en,
	input	 	[6:0] 	addr,
	input 		[7:0] 	data_w,
	output  reg [7:0] 	data_r,
	output  reg 		calc_done
);

reg [6:0] addr_d;			//储存上一次的地址
reg [7:0] data_temp;		//用于保存第一次出现的运算符号
reg       data_temp_en;	 	//使能信号，防止第二次出现运算地址时再读入运算符号
reg [1:0] data_counter;
reg [31:0] data_data_temp;
reg [31:0] data_r_temp;   
reg [1:0] data_r_counter;
reg [3:0] spi_counter;
//检测write_vld的下降沿
reg 	  write_vld_d0;
reg 	  write_vld_d1;
wire	  write_vld_neg;  //为1表示检测到下降沿

//对write_vld信号延时
always @(posedge clk or negedge rst_n)begin
	if(!rst_n)begin
		write_vld_d0 <= 0;
		write_vld_d1 <= 0;
	end
	else begin
		write_vld_d0 <= write_vld;
		write_vld_d1 <= write_vld_d0;
	end
end
//当检测到write_vld下降沿时，neg为1
assign write_vld_neg = write_vld_d0&(~write_vld_d1);

//储存上一次的地址
always @(posedge clk or negedge rst_n)begin
	if(~rst_n)
		addr_d<=7'b0;
	else if(write_vld_neg)
		addr_d<=addr;
end

//进行计算（仅在检测到write_vld下降沿后，对所有数据进行运算）
always @(posedge clk or negedge rst_n)begin
	if(~rst_n)
		data_r_temp <= 32'b0;
	else if(calc_done && write_vld_neg)
		data_r_temp <= data_data_temp;  				//完成一次计算后，让下一次计算开始时输出data_r等于data_w，实现清空上一轮的计算结果
	else if(addr_d != addr && write_vld_neg)begin	//只有地址不同时才进行一次运算
		if(addr==7'd2)begin				//出现数字地址时，通过判断储存的运算符，直接与该帧数据进行运算
			case(data_temp)
				8'h10: data_r_temp <= data_r_temp+data_data_temp;		//加法运算		
				8'h20: data_r_temp <= data_r_temp-data_data_temp;		//减法运算
				default:;
			endcase
		end
	end
	else if(data_r_counter == 3)  //如果完成计算，发送完前24位后清空前24位
		data_r_temp = {24'b0,data_r_temp[7:0]};
end

always @(posedge clk or negedge rst_n)begin
	if(~rst_n)
		data_data_temp <= 32'b0;
	else if(calc_done && write_vld_neg)
		data_data_temp[7:0] <= data_w; 
	else if(addr_d==7'd1 && addr==7'd1 && data_counter!=2'd3)
		data_data_temp <= {data_data_temp[23:0],data_w};
end


always @(posedge clk or negedge rst_n)begin
	if(~rst_n)
		data_counter <= 2'b0;
	else if((calc_done || addr==7'd2) && write_vld_neg)
		data_counter <= 2'b0; 
	else if(addr_d==7'd1 && addr==7'd1)begin
		if(data_counter==2'd3)
			data_counter<=data_counter;
		else
			data_counter <= data_counter+1'b1;
	end
end


	
always @(posedge clk or negedge rst_n)begin
	if(~rst_n || calc_done)begin		//完成一次计算后，等待输入符号
		data_temp <= 8'h10;
		data_temp_en <= 1'b0;
	end
	else if(addr==7'd2 && ~data_temp_en && write_vld_neg)begin
		data_temp<=data_w;				//地址为2，输入符号
		data_temp_en <= 1'b1;			//此时已经读入符号，en拉高
	end
	else if(addr==7'd1 && write_vld_neg)begin
		data_temp<=data_temp;			//地址为1，符号不变
		data_temp_en <= 1'b0;			//输入了数字，可以重新输入符号，en拉低
	end
end
		
always @(posedge clk or negedge rst_n)begin
	if(~rst_n)
		calc_done<=1'b0;
	else if(addr == 8'h02 && data_w==8'h30 && write_vld_neg)//计算完成标志
		calc_done<=1'b1;
	else if(write_vld_neg)
		calc_done<=1'b0;
end


always @(posedge sclk or negedge rst_n)begin
	if(~rst_n)
		spi_counter <= 0;
	else if(spi_counter < 15)
		spi_counter <= spi_counter + 1;
	else if(spi_counter == 15)
		spi_counter <= 0;
end
always @(posedge sclk or negedge rst_n)begin
	if(~rst_n)
		data_r_counter <= 0;
	else if(calc_done && data_r_counter != 3 && spi_counter == 15)
		data_r_counter <= data_r_counter + 1;
	else if(!calc_done)
		data_r_counter <= 0;
end
always @(posedge sclk or negedge rst_n)begin
	if(~rst_n)
		data_r<=0;
	else if(calc_done)begin
		case(data_r_counter)
			2'd0:data_r<=data_r_temp[31:24];
			2'd1:data_r<=data_r_temp[23:16];
			2'd2:data_r<=data_r_temp[15:8];
			2'd3:data_r<=data_r_temp[7:0];
		endcase
	end
end


endmodule