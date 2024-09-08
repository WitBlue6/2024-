	`timescale 1ns/1ps
module crc_8(
	input clk, 
	input rst_n,
	input [63:0] din,  
	input crc_start,  
	//output
	output crc_vld,  
	output [7:0] crc_o  
);
//parameter define
parameter fx = 9'b1_0000_0111;  //x8+x2+x1+1

//reg define
reg [71:0] din_r;  //扩展8位后的数据
reg [6:0] din_cnt = 7'd0;  // 模2运算到的数据位的计数
reg [7:0] crc;  // 储存CRC
reg vld = 1'b0; //CRC高有效
reg [8:0] tmp_r;  //储存以1开头的余数
reg [8:0] total_r;  //储存包含以0为开头的余数
reg r_flag = 1'b0;  //开始计算以1开头的余数
reg [3:0] r_cnt = 4'd0;  //total_r的计数
reg [3:0] r_cnt1 = 4'd0; //tmp_r的计数
reg initial_flag = 1'b1;  //判断是否为初始化状态

//wire define
wire [7:0] crc_O;


//main
always@(posedge clk or negedge rst_n)begin
	if(!rst_n)begin
		crc <= 8'd0;
		din_cnt = 7'd0;
		vld <= 1'b0;
		initial_flag <= 1'b1;
		r_cnt <= 4'd0;
		r_cnt1 <= 4'd0;
	end
	if(crc_start && vld == 1'b0)begin
		//initial
		if(initial_flag)begin
			tmp_r[8:0] = din[63:55];  //最开始让余数等于数据前九位
			din_cnt = 7'd9;  //最开始已经计算了前九位的余数
			initial_flag <= 1'b0;
			din_r <= {din, 8'b0000_0000};  //数据位扩展8位
		end
		else if(din_cnt == 7'd72)begin//当数据位全部运算完成，结束
			vld <= 1'b1;  //高有效
			//此时tmp_r中储存了有效的余数，r_cnt1表示有效的位数
			case(r_cnt1)
				4'd1: crc <= {7'b000_0000, tmp_r[8]};
				4'd2: crc <= {6'b00_0000, tmp_r[8:7]};
				4'd3: crc <= {5'b0_0000, tmp_r[8:6]};
				4'd4: crc <= {4'b0000, tmp_r[8:5]};
				4'd5: crc <= {3'b000, tmp_r[8:4]};
				4'd6: crc <= {2'b00, tmp_r[8:3]};
				4'd7: crc <= {1'b0, tmp_r[8:2]};
				4'd8: crc <= tmp_r[8:1];
				4'd9: crc <= tmp_r[7:0]^fx[7:0];  //此时重新补齐9位，需要再进行一次异或运算
			endcase
		end
		else begin  //进行模2除法
			if(tmp_r[8-(r_cnt+4'd0)-:1]^fx[8-(r_cnt+4'd0)-:1]==0 && r_flag==0)begin //异或为0，只计入total_r，不计入tmp_r
				r_cnt <= r_cnt + 1;
				//total_r储存
				total_r[8-(r_cnt+4'd0)-:1] <= tmp_r[8-(r_cnt+4'd0)-:1]^fx[8-(r_cnt+4'd0)-:1];
			end
			//r_flag为1，异或结果为1
			else begin
				r_flag <= 1;  
				if(r_cnt == 9 && r_cnt1 < 9)begin //total_r已经计满，而tmp_r未计满，需要从din_r中补位数
					tmp_r[8-(r_cnt1+4'd0)-:1] <= din_r[71-(din_cnt+7'd0)-:1];
					r_cnt <= 9;
					din_cnt <= din_cnt + 1;
					r_cnt1 <= r_cnt1 + 1;
				end
				else if(r_cnt1 == 9)begin  //tmp_r计满
					r_cnt1 <= 0;
					r_cnt <= 0;
					r_flag <= 0;  //模2运算结束
				end
				else begin   //进行模2运算，计入total_r和tmp_r
					tmp_r[8-(r_cnt1+4'd0)-:1] <= tmp_r[8-(r_cnt+4'd0)-:1]^fx[8-(r_cnt+4'd0)-:1];
					total_r[8-(r_cnt+4'd0)-:1] <= tmp_r[8-(r_cnt+4'd0)-:1]^fx[8-(r_cnt+4'd0)-:1];
					r_cnt1 <= r_cnt1 + 1;
					r_cnt <= r_cnt + 1;
				end
			end
		end
	end
end


assign crc_o = crc;
assign crc_vld = vld;

endmodule