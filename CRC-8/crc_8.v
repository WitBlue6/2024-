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
reg [71:0] din_r;  //��չ8λ�������
reg [6:0] din_cnt = 7'd0;  // ģ2���㵽������λ�ļ���
reg [7:0] crc;  // ����CRC
reg vld = 1'b0; //CRC����Ч
reg [8:0] tmp_r;  //������1��ͷ������
reg [8:0] total_r;  //���������0Ϊ��ͷ������
reg r_flag = 1'b0;  //��ʼ������1��ͷ������
reg [3:0] r_cnt = 4'd0;  //total_r�ļ���
reg [3:0] r_cnt1 = 4'd0; //tmp_r�ļ���
reg initial_flag = 1'b1;  //�ж��Ƿ�Ϊ��ʼ��״̬

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
			tmp_r[8:0] = din[63:55];  //�ʼ��������������ǰ��λ
			din_cnt = 7'd9;  //�ʼ�Ѿ�������ǰ��λ������
			initial_flag <= 1'b0;
			din_r <= {din, 8'b0000_0000};  //����λ��չ8λ
		end
		else if(din_cnt == 7'd72)begin//������λȫ��������ɣ�����
			vld <= 1'b1;  //����Ч
			//��ʱtmp_r�д�������Ч��������r_cnt1��ʾ��Ч��λ��
			case(r_cnt1)
				4'd1: crc <= {7'b000_0000, tmp_r[8]};
				4'd2: crc <= {6'b00_0000, tmp_r[8:7]};
				4'd3: crc <= {5'b0_0000, tmp_r[8:6]};
				4'd4: crc <= {4'b0000, tmp_r[8:5]};
				4'd5: crc <= {3'b000, tmp_r[8:4]};
				4'd6: crc <= {2'b00, tmp_r[8:3]};
				4'd7: crc <= {1'b0, tmp_r[8:2]};
				4'd8: crc <= tmp_r[8:1];
				4'd9: crc <= tmp_r[7:0]^fx[7:0];  //��ʱ���²���9λ����Ҫ�ٽ���һ���������
			endcase
		end
		else begin  //����ģ2����
			if(tmp_r[8-(r_cnt+4'd0)-:1]^fx[8-(r_cnt+4'd0)-:1]==0 && r_flag==0)begin //���Ϊ0��ֻ����total_r��������tmp_r
				r_cnt <= r_cnt + 1;
				//total_r����
				total_r[8-(r_cnt+4'd0)-:1] <= tmp_r[8-(r_cnt+4'd0)-:1]^fx[8-(r_cnt+4'd0)-:1];
			end
			//r_flagΪ1�������Ϊ1
			else begin
				r_flag <= 1;  
				if(r_cnt == 9 && r_cnt1 < 9)begin //total_r�Ѿ���������tmp_rδ��������Ҫ��din_r�в�λ��
					tmp_r[8-(r_cnt1+4'd0)-:1] <= din_r[71-(din_cnt+7'd0)-:1];
					r_cnt <= 9;
					din_cnt <= din_cnt + 1;
					r_cnt1 <= r_cnt1 + 1;
				end
				else if(r_cnt1 == 9)begin  //tmp_r����
					r_cnt1 <= 0;
					r_cnt <= 0;
					r_flag <= 0;  //ģ2�������
				end
				else begin   //����ģ2���㣬����total_r��tmp_r
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