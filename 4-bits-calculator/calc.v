module calc(
	input 				clk,
	input 				rst_n,
	input 				write_vld,
	input 				read_en,
	input	 	[6:0] 	addr,
	input 		[7:0] 	data_w,
	output  reg [7:0] 	data_r,
	output  reg 		calc_done
);

reg		[1:0]		c_state;
reg		[1:0]		n_state;
reg					write_vld_d1;
reg					write_vld_d2;
reg					write_vld_d3;
reg					op;
reg		[7:0]		result;

parameter 			s_idle = 0;
parameter 			s_data = 1;
parameter 			s_op   = 2;

always @(posedge clk or negedge rst_n)begin
	if(~rst_n)begin
		write_vld_d1 <= 0;
		write_vld_d2 <= 0;
		write_vld_d3 <= 0;
	end
	else begin
		write_vld_d1 <= write_vld;
		write_vld_d2 <= write_vld_d1;
		write_vld_d3 <= write_vld_d2;
	end
end

assign in_vld = write_vld_d2 & ~write_vld_d3;

always @(posedge clk or negedge rst_n)begin
	if(~rst_n)
		c_state <= s_idle;
	else
		c_state <= n_state;
end

always @(posedge clk or negedge rst_n)begin
	if(~rst_n)
		op <= 1;
	else if(c_state == s_data && n_state == s_op)
		op <= (data_w == 8'h10);
end

always @(posedge clk or negedge rst_n)begin
	if(~rst_n)
		result <= 8'd0;
	else if(c_state == s_data)begin
		if(op)
			result <= result + data_w;
		else
			result <= result - data_w;
	end
	else if (c_state==s_idle && n_state==s_data)
		result <= data_w;
end

always @(posedge clk or negedge rst_n)begin
	if(~rst_n)
		calc_done <= 0;
	else if(c_state == s_data && n_state == s_idle)
		calc_done <= 1;
	else if(c_state == s_idle && n_state == s_data)
		calc_done <= 0;
end

always @(posedge clk or negedge rst_n)begin
	if(~rst_n)
		data_r <= 8'd0;
	else if(read_en && addr == 7'h04)
		data_r <= result;
end

always @* begin
	if(in_vld)begin
		case(c_state)
			s_idle:begin
				if(addr == 7'h01)
					n_state = s_data;			
				else
					n_state = c_state;
			end
			s_data:begin
				if(addr == 7'h02)begin
					if(data_w == 8'h30)
						n_state = s_idle;
					else if(data_w == 8'h10 || data_w == 8'h20)
						n_state = s_op;
				end
				else
					n_state = c_state;
			end
			s_op: begin
				if(addr == 7'h01)
					n_state = s_data;
				else
					n_state = c_state;
			end
			default: n_state = c_state;
	end
	else
		n_state = c_state;
end

endmodule