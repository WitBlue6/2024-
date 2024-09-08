module cvsd(
	input				clk_10k,	
	input				rst_n,
	input		[7:0]	x,
	output				V2,
	output	reg	[7:0]	xp,			
	output				flag		//3连
);

parameter	beta  = 48;		
parameter	delta =	1;
parameter	step0 = 10;

reg		[7:0]	step;
reg				V2_d1;
reg				V2_d2;
reg				V2_d3;

always @(posedge clk_10k or negedge rst_n)begin
	if(~rst_n)begin
		V2_d1 <= 1;
		V2_d2 <= 0;
		V2_d3 <= 0;
	end
	else begin
		V2_d1 <= V2;
		V2_d2 <= V2_d1;
		V2_d3 <= V2_d2;
	end
end

assign flag = (V2==V2_d1) && (V2==V2_d2);


always @(posedge clk_10k or negedge rst_n)begin
	if(~rst_n)
		step <= step0;
	else if(flag)
		step <= (beta * step) / 50 + delta;
	else
		step <= (beta * step) / 50;
end

always @(posedge clk_10k or negedge rst_n)begin
	if(~rst_n)
		xp <= 8'd128;
	else if(V2)
		xp <= xp + step;
	else
		xp <= xp - step;
end

assign V2 = (xp <= x) ? 1'b1 : 1'b0;

endmodule