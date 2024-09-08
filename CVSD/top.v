module top(
	input 					CLOCK,			//50MHz
	output 					CLOCK_DIV,		//10KHz
	output 					flag,
	input 					RESET,
	output 			[7:0]	V1,			//sin out
	output 					V2,			//CVSD out
	output 					V3,
	output 			[7:0]	xp			
);

clock_div u_clock_div(
	.clk_in			(CLOCK),
	.rst_n			(RESET),
	.clk_out		(CLOCK_DIV)
);

sin_generater u_sin_generater(
	.clk_10k		(CLOCK_DIV),
	.rst_n			(RESET),
	.sin_out		(V1)
);

cvsd u_cvsd(
	.clk_10k	(CLOCK_DIV),	
	.rst_n		(RESET),
	.x			(V1),
	.V2			(V2),
	.xp			(xp),
	.flag		(flag)
);  
 
check u_check(
	.CLOCK_DIV	(CLOCK_DIV),
	.RESET		(RESET),
	.V2			(V2),
	.V3			(V3)
);
endmodule