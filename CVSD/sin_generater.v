module sin_generater(
	input				clk_10k,
	input				rst_n,
	output	reg	 [7:0]	sin_out
);

reg		[4:0]	sin_cnt;

always @(posedge clk_10k or negedge rst_n)begin
	if(~rst_n)
		sin_cnt <= 5'd0;
	else if(sin_cnt == 5'd19)
		sin_cnt <= 5'd0;
	else
		sin_cnt <= sin_cnt + 5'd1;
end

always @(posedge clk_10k or negedge rst_n)begin
	if(~rst_n)
		sin_out <= 8'd128;
	else begin
		case(sin_cnt)
			5'd0 :	sin_out <= 8'd128;		
			5'd1 :	sin_out <= 8'd167;
			5'd2 :	sin_out <= 8'd203;
			5'd3 :	sin_out <= 8'd231;
			5'd4 :	sin_out <= 8'd250;
			5'd5 :	sin_out <= 8'd255;
			5'd6 :	sin_out <= 8'd250;
			5'd7 :	sin_out <= 8'd231;
			5'd8 :	sin_out <= 8'd203;
			5'd9 :	sin_out <= 8'd167;
			5'd10:	sin_out <= 8'd128;
			5'd11:	sin_out <= 8'd88;
			5'd12:	sin_out <= 8'd53;
			5'd13:	sin_out <= 8'd24;
			5'd14:	sin_out <= 8'd6;
			5'd15:	sin_out <= 8'd0;
			5'd16:	sin_out <= 8'd6;
			5'd17:	sin_out <= 8'd24;
			5'd18:	sin_out <= 8'd53;
			5'd19:	sin_out <= 8'd88;
		endcase
	end
end

endmodule