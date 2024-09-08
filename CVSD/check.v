module check(CLOCK_DIV,RESET,V2,V3);
input		CLOCK_DIV;
input		RESET;
input		V2;
output	reg	V3;

parameter	s_0		=	3'd0;
parameter	s_1		=	3'd1;
parameter	s_11	=	3'd2;
parameter	s_111	=	3'd3;
parameter	s_1110	=	3'd4;

reg	[2:0]	c_state;
reg	[2:0]	n_state;

always @(posedge CLOCK_DIV or negedge RESET)begin
	if(~RESET)
		c_state<=s_0;
	else
		c_state<=n_state;
end

always @(*)begin
	case(c_state)
		s_0:begin
				if(V2==1'b1)	
					n_state=s_1;
				else			
					n_state=s_0;
		end
		s_1:begin
				if(V2==1'b1)
					n_state=s_11;
				else
					n_state=s_0;
		end
		s_11:begin
				if(V2==1'b1)
					n_state=s_111;
				else
					n_state=s_0;
		end
		s_111:begin
				if(V2==1'b0)
					n_state=s_1110;
				else
					n_state=s_111;
		end
		s_1110:begin
				if(V2==1'b0)
					n_state=s_0;
				else
					n_state=s_1;
		end
		default:n_state=c_state;
	endcase
end		

always @(posedge CLOCK_DIV or negedge RESET)begin
	if(~RESET)
		V3<=1'b0;
	else if(c_state==s_1110 && n_state==s_0)
		V3<=1'b1;
	else
		V3<=1'b0;
end


endmodule