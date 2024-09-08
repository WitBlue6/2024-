module tb_top();

  reg           sclk;
  reg           cs_n;
  reg           mosi;
  wire          miso;
  reg           rst_n;
  wire          write_vld;
  wire          read_en;
  wire    [6:0] addr;
  wire    [7:0] data_w;
  reg     [7:0] data_r;
  reg     [2:0] test_case;
  reg     [7:0] data_read;
  
spi_slave u_spi_slave ( .sclk(sclk), 
                        .cs_n(cs_n), 
                        .mosi(mosi), 
                        .miso(miso), 
                        .rst_n(rst_n), 
                        .write_vld(write_vld), 
                        .read_en(read_en), 
                        .addr(addr), 
                        .data_w(data_w), 
                        .data_r(data_r));  
                        
initial begin
    sclk = 1'b0;
    cs_n = 1'b1;
    sclk = 1'b0;
    mosi = 1'b0;
    rst_n = 1'b1;
    data_r = 8'h33;
    test_case = 0;
    
    #10053  rst_n = 1'b0;
    #100000 rst_n = 1'b1;
    
    test_case = 3'd1;
    write_data(7'd3, 8'h11);
    #500000;
    test_case = 3'd2;
    write_data(7'd7, 8'h22);
    #500000;
    test_case = 3'd3;
    read_data(7'd4, data_read);
    #500000;
    test_case = 3'd0;
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