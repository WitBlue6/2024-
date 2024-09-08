module pwm(
	input				clk_100m,  //256MHz
	input				rst_n,
	input		[2:0]	freq,
	output	reg			pwm_o,
	output	reg	[7:0]	data_o
);

reg		[7:0]		pwm_cnt;

reg		[7:0]		sine_rom[0:1023];
reg		[9:0]		sine_cnt;
reg		[7:0]		saw;
reg		[7:0]		freq_cnt;

initial begin
	$readmemh("sine_wave.rom", sine_rom);
end

always @(posedge clk_100m or negedge rst_n)begin
	if(~rst_n)
		pwm_cnt <= 8'd0;
	else if(pwm_cnt == 8'd255)
		pwm_cnt <= 8'd0;
	else
		pwm_cnt <= pwm_cnt + 8'd1;
end

always @(posedge clk_100m or negedge rst_n)begin
	if(~rst_n)
		saw <= -127;
	else if(pwm_cnt < 8'd127)
		saw <= saw + 2;
	else if(pwm_cnt >8'd128)
		saw <= saw - 2;
end

always @(posedge clk_100m or negedge rst_n)begin
	if(~rst_n)
		freq_cnt <= 0;
	else if(freq_cnt < (8'd255 >> freq))
		freq_cnt <= freq_cnt + 1;
	else
		freq_cnt <= 0;
end
always @(posedge clk_100m or negedge rst_n)begin
	if(~rst_n)
		sine_cnt <= 10'd0;
	else if(freq_cnt >= (8'd255 >> freq))begin
		if(sine_cnt < 10'd1023)
			sine_cnt <= sine_cnt + 1;
		else
			sine_cnt <= 10'd0;
	end
end

always @(posedge clk_100m or negedge rst_n)begin
	if(~rst_n)
		pwm_o <= 0;
	else if($signed(sine_rom[sine_cnt]) < $signed(saw))
		pwm_o <= 0;
	else
		pwm_o <= 1;
end

always @(posedge clk_100m or negedge rst_n)begin
	if(~rst_n)
		data_o <= 8'd0;
	else
		data_o <= sine_rom[sine_cnt];
end


endmodule