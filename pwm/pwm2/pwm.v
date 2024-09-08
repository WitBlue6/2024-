module pwm(clk_256M,rst_n,freq,pwm_o,data_o);
input			clk_256M;
input			rst_n;
input	[2:0]	freq;
output			pwm_o;
output	[7:0]	data_o;



wire	[7:0]	rom_data;
reg		[7:0]	pwm_cnt;
reg		[9:0]	addr;

always @(posedge clk_256M or negedge rst_n)begin
	if(~rst_n)
		pwm_cnt <= 8'd0;
	else
		pwm_cnt <= pwm_cnt + 8'd1;
end

assign pwm_o = (rom_data > pwm_cnt) ? 1'b1 : 1'b0;
assign data_o = rom_data;

always @(posedge clk_256M or negedge rst_n)begin
	if(~rst_n)
		addr <= 10'd0;
	else if(pwm_cnt == 8'd255)
		addr <= addr + (10'd1 << freq);
end

rom u_rom(
	.addr(addr),
	.data(rom_data)
);

endmodule