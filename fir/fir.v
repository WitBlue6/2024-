`timescale 1ns/1ps
module fir(
	input			clk_100k,
	input			rst_n,
	input 	signed [8:0]	samp_in,
	output 	signed [8:0]	fir_out	
);

// coe define
reg	signed [15:0]	b[0:20];
// shift reg define
reg	signed [8:0]	samp[0:20]; 

// mult calculater define
wire signed [24:0]	mult[0:20];
wire signed [33:0]	sum;

initial begin
	b[0]   = 16'h0312;
	b[1]   = 16'h03F8;
	b[2]   = 16'h0694;
	b[3]   = 16'h0AAD;
	b[4]   = 16'h0FE6;
	b[5]   = 16'h15BC;
	b[6]   = 16'h1B9F;
	b[7]   = 16'h20F9;
	b[8]   = 16'h2539;
	b[9]   = 16'h27F6;
	b[10]  = 16'h28E9;
	b[11]  = 16'h27F6;
	b[12]  = 16'h2539;
	b[13]  = 16'h20F9;
	b[14]  = 16'h1B9F;
	b[15]  = 16'h15BC;
	b[16]  = 16'h0FE6;
	b[17]  = 16'h0AAD;
	b[18]  = 16'h0694;
	b[19]  = 16'h03F8;
	b[20]  = 16'h0312;
end
//shift 
integer i;
always @(posedge clk_100k or negedge rst_n) begin
	if(!rst_n) begin
		for(i=20;i>=0;i=i-1)begin
			samp[i] <= 0;
		end
	end
	else begin  
		for(i=20;i>0;i=i-1)begin
			samp[i] <= samp[i-1];
		end
		samp[0] <= samp_in;
	end
end

//mult calculate
genvar j;
for(j=0;j<=20;j=j+1)begin
	assign mult[j] = $signed(samp[j])*$signed(b[j]);
end

//sum 
assign sum = mult[0]+mult[1]+mult[2]+mult[3]+mult[4]+mult[5]+mult[6]+mult[7]+mult[8]+mult[9]+mult[10]+mult[11]+mult[12]+mult[13]+mult[14]+mult[15]+mult[16]+mult[17]+mult[18]+mult[19]+mult[20];

//data out
assign fir_out = sum[24:16];

endmodule
