// Copyright (C) 1991-2012 Altera Corporation
// Your use of Altera Corporation's design tools, logic functions 
// and other software and tools, and its AMPP partner logic 
// functions, and any output files from any of the foregoing 
// (including device programming or simulation files), and any 
// associated documentation or information are expressly subject 
// to the terms and conditions of the Altera Program License 
// Subscription Agreement, Altera MegaCore Function License 
// Agreement, or other applicable license agreement, including, 
// without limitation, that your use is for the sole purpose of 
// programming logic devices manufactured by Altera and sold by 
// Altera or its authorized distributors.  Please refer to the 
// applicable agreement for further details.

// *****************************************************************************
// This file contains a Verilog test bench template that is freely editable to  
// suit user's needs .Comments are provided in each section to help the user    
// fill out necessary details.                                                  
// *****************************************************************************
// Generated on "11/17/2020 13:18:43"
                                                                                
// Verilog Test Bench template for design : top
// 
// Simulation tool : ModelSim (Verilog)
// 

`timescale 1 ns/ 1 ps
module top_vlg_tst();
// constants
localparam clk_period=20;                                           
// general purpose registers
reg eachvec;
// test vector input registers
reg CLOCK;
reg RESET;

// wires                                               
wire CLOCK_DIV;
wire flag;
wire [7:0]  V1;
wire V2;
wire V3;
wire [7:0]  xp;

// assign statements (if any)                          
top i1 (
// port map - connection between master ports and signals/registers   
	.CLOCK(CLOCK),
	.CLOCK_DIV(CLOCK_DIV),
	.flag(flag),
	.RESET(RESET),
	.V1(V1),
	.V2(V2),
	.V3(V3),
	.xp(xp)
);
initial                                                
begin                                                  
// code that executes only once                        
// insert code here --> begin                
	CLOCK = 0;
	RESET=1;
	#(10000);
	RESET=0;
	@(posedge CLOCK);
	RESET=1;
	repeat(10) begin
		@(posedge V3);
	end
	$stop();
// --> end                                                               
end                                                    
always #(clk_period/2) CLOCK = ~CLOCK;                                        
endmodule

