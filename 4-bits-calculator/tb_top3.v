
module tb_top3();

  reg           clk;
  reg           sclk;
  reg           cs_n;
  reg           mosi;
  wire          miso;
  reg           rst_n;
  wire          calc_done;
  reg     [2:0] test_case;
  reg     [7:0] data_read;
  
calc_top2 u_calc_top2 ( .clk(clk),
                        .sclk(sclk), 
                        .cs_n(cs_n), 
                        .mosi(mosi), 
                        .miso(miso), 
                        .rst_n(rst_n), 
                        .calc_done(calc_done));

always #500 clk = ~clk;
                        
initial begin
    clk = 1'b0;
    sclk = 1'b0;
    cs_n = 1'b1;
    sclk = 1'b0;
    mosi = 1'b0;
    rst_n = 1'b1;
    test_case = 3'd0;

    
    #10053  rst_n = 1'b0;
    #100000 rst_n = 1'b1;
    
    #1000000;
    test_case = 3'd6;
    write_data(7'd1, 8'h3C);
    #500000;
    write_data(7'd2, 8'h10);
    #500000;
    write_data(7'd1, 8'h11);
    #500000;
    write_data(7'd1, 8'h20);
    #500000;
    write_data(7'd1, 8'h2);
    #500000;
    write_data(7'd2, 8'h30);
    #500000;
    if (calc_done) begin
    read_data(7'd7, data_read);
    #500000;
    read_data(7'd6, data_read);
    #500000;
    read_data(7'd5, data_read);
    #500000;
    read_data(7'd4, data_read);
    #500000;
    end


    test_case = 3'd7;
    write_data(7'd1, 8'h01);
    #500000;
    write_data(7'd1, 8'h02);
    #500000;
    write_data(7'd1, 8'h05);
    #500000;
    write_data(7'd1, 8'h07);
    #500000;
    write_data(7'd1, 8'h05);
    #500000;
    write_data(7'd2, 8'h20);
    #500000;
    write_data(7'd1, 8'h02);
    #500000;
    write_data(7'd1, 8'h03);
    #500000;
    write_data(7'd2, 8'h30);
    #500000;
    if (calc_done) begin
    read_data(7'd7, data_read);
    #500000;
    read_data(7'd6, data_read);
    #500000;
    read_data(7'd5, data_read);
    #500000;
    read_data(7'd4, data_read);
    #500000;
    test_case = 0;
    #500000;
    end


    #1000000 $stop;
    
  end
  
  
/************************************************************/
//  task write_data
/************************************************************/

task write_data;
input   [6:0]   address;
input   [7:0]  data_wr;

integer i;
begin
#50000 cs_n  = 1'b0;
#50000 sclk  = 1'b1;
       mosi  = 1'b0;
#50000 sclk  = 1'b0;
    i=6;
repeat(7)
begin 
  #50000 sclk = 1'b1;
         mosi = address[i];
  #50000 sclk = 1'b0;
      i=i-1;
end
    i=7;
repeat(8)
begin 
  #50000 sclk = 1'b1;
         mosi = data_wr[i];
  #50000 sclk = 1'b0;
      i=i-1;
end
#50000 cs_n = 1'b1;
#50000;   
end 
endtask  


/************************************************************/
//  task read_data
/************************************************************/

task read_data;
input   [6:0]   address;
output  [7:0]   data_out;

integer i;
begin
#50000 cs_n = 1'b0;
#50000 sclk = 1'b1;
       mosi = 1'b1;
#50000 sclk = 1'b0;
    i=6;
repeat(7)
begin 
  #50000 sclk = 1'b1;
         mosi = address[i];
  #50000 sclk = 1'b0;
      i=i-1;
end

i=7;
data_out <= 8'b0;
repeat(8)
begin 
  #50000 sclk = 1'b1;
  #50000 sclk = 1'b0;
      data_out <= {data_out[6:0], miso};
      i=i-1;
end
#50000 cs_n = 1'b1;
#50000;   
end 
endtask    
  
  
  
  
  
endmodule


