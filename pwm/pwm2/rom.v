module rom(addr, data);
input 	[9:0]	addr;
output	[7:0]	data;

reg		[7:0]	mem[0:1023];

initial begin
	$readmemh("sin_wave_samples.mem", mem);
end

assign data = mem[addr];

endmodule