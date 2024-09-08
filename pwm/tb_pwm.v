`timescale 1ns/1ps
module tb_pwm();

reg				clk_100m;
reg				rst_n;
wire			pwm_o;
wire	[7:0]	data_o;
reg		[2:0]	freq;
initial begin
	clk_100m = 0;
	rst_n = 0;
	repeat(4)begin
		@(posedge clk_100m);
	end
	
	rst_n = 1;
	
	@(posedge clk_100m)
	freq = 0;
	repeat(4)begin
		repeat(1024*256)begin
			@(posedge clk_100m);
		end
	end
	
	@(posedge clk_100m)
	freq = 1;
	repeat(4)begin
		repeat(512*256)begin
			@(posedge clk_100m);
		end
	end
	
	@(posedge clk_100m)
	freq = 2;
	repeat(4)begin
		repeat(256*256)begin
			@(posedge clk_100m);
		end
	end
	
	@(posedge clk_100m)
	freq = 3;
	repeat(4)begin
		repeat(128*256)begin
			@(posedge clk_100m);
		end
	end
	
	@(posedge clk_100m)
	freq = 4;
	repeat(4)begin
		repeat(64*256)begin
			@(posedge clk_100m);
		end
	end
	
	freq = 5;
	repeat(4)begin
		repeat(32*256)begin
			@(posedge clk_100m);
		end
	end
	
	freq = 6;
	repeat(4)begin
		repeat(16*256)begin
			@(posedge clk_100m);
		end
	end
	
	freq = 7;
	repeat(4)begin
		repeat(8*256)begin
			@(posedge clk_100m);
		end
	end
	
	$stop();
end

always #2 clk_100m = ~clk_100m;

pwm u_pwm(
	.clk_100m (clk_100m) ,
	.rst_n    (rst_n) ,
	.freq     (freq) ,
	.pwm_o    (pwm_o) ,
	.data_o   (data_o)
);           

endmodule