// Asynchronous FIFO Code

  module asyncfifo(wrclk,rdclk,wr_reset,rd_reset,wr_data,rd_data,empty,full,wr_en,rd_en);
  input wrclk,rdclk,wr_reset,rd_reset,wr_en,rd_en;
  input [7:0]wr_data;
  output reg [7:0]rd_data;
  output reg empty,full; 
  
  reg [7:0]mem[10];
  reg [3:0]wraddr,rdaddr;
  reg [4:0]wrptr,rdptr;
  
  reg [4:0]sync1_wrptr,sync1_rdptr;
  reg [4:0]sync_wrptr,sync_rdptr;
  
 
  assign wraddr=wrptr[3:0];
  assign rdaddr=rdptr[3:0];
  
  assign full=((wrptr[4]!=sync_rdptr[4])&&(wrptr[3:0]==sync_rdptr[3:0]))?1'b1:1'b0;
  
  assign empty=(rdptr==sync_wrptr)?1'b1:1'b0;
  
  //Write pointer logic 
  
    always@(posedge wrclk or negedge wr_reset) begin 
    if(wr_reset==1'b0) begin 
      wrptr<=0;
    end 
    else if(wr_en && !full)  begin      
      if(wrptr==9) begin
        wrptr[4]=~wrptr[4];
        wrptr[3:0]=0;
      end
     else
     wrptr<=wrptr+1;
    end
else
wrptr <= wrptr;
  end 

  // write data logic inside the memory 
    always@(posedge wrclk or negedge wr_reset ) begin 
    if(wr_reset==1'b0) begin 
      
      for(int i=0;i<10;i=i+1)
        mem[i]<=0;
    end 
    else if(wr_en && !full) begin 
      mem[wraddr]<=wr_data;
  end 
  end

  
 // Read Pointer logic 
    always@(posedge rdclk or negedge rd_reset) begin 
    if(rd_reset==1'b0) begin 
      rdptr<=0;
    end 
    else if(rd_en && !empty) begin      
      if(rdptr==9) begin
        rdptr[4]=~rdptr[4];
        rdptr[3:0]=0;
      end
     else
    rdptr<=rdptr+1;
    end
else
rdptr <= rdptr;
end 

   //Read Data from the memory 
    always @(posedge rdclk or negedge rd_reset )begin
   if(rd_reset == 1'b0)begin
   rdptr <= 0;
   end
   else if(rd_en && !empty)begin
   rd_data <= mem[rdaddr];
   end
   end
  
//Synchronizer logic for sync_rdptr during full
  
  always @(posedge wrclk) begin 
    if(wr_reset==1'b0) begin
    sync_rdptr <=0;
    sync1_rdptr <= 0;
    rdptr<=5'b0000;

    end
    else begin 
      sync1_rdptr<=rdptr;
      sync_rdptr<=sync1_rdptr;
    end
  end 
  
   //Synchronizer logic for wr_rdptr during empty
  
  always @(posedge rdclk) begin 
    if(rd_reset==1'b0) begin
      sync_wrptr<=0;
      sync1_wrptr<=0;
     wrptr<=5'b0000;
end
    
    else begin 
      sync1_wrptr<=wrptr;
      sync_wrptr<=sync1_wrptr;
    end
  end
  
  
endmodule
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// FIFO -TB 

module tb;
  reg wrclk=1'b0,rdclk=1'b0,wr_reset,rd_reset,wr_en,rd_en;
  reg [7:0]wr_data;
  wire empty,full;
  wire [7:0]rd_data;
  
  asyncfifo dut(.wrclk(wrclk),.rdclk(rdclk),.wr_reset(wr_reset),.rd_reset(rd_reset),.wr_data(wr_data),.rd_data(rd_data),.empty(empty),.full(full),.wr_en(wr_en),.rd_en(rd_en)); 
  
  always #5 wrclk=~wrclk;
  always #5 rdclk=~rdclk;
  
  initial begin 
    wr_reset=1'b0;
    #10 wr_reset=1'b1;
  end 
  
    initial begin 
    rd_reset=1'b0;
    #10 rd_reset=1'b1;
  end 
  
  initial begin 
    wr_en=1'b0;
    #10 wr_en=1'b1;
    
    #150 wr_en=1'b0;
  end 
  
  initial begin 
    rd_en=1'b0;
    
    #160 
    rd_en=1'b1;
  end 
  
  initial begin 
    wr_data=0;
    @(posedge wrclk);
     
    repeat(12) begin
      @(posedge wrclk)
      wr_data=$urandom_range(20,100);
    end
  end 
  
  initial begin 
    $dumpfile("dump.vcd");
    $dumpvars();
    #400 $finish();
  end

  
endmodule  
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
Synchronous FIFO Code
  module syncfifo(clk,rst,wr_data,rd_data,empty,full,wr_en,rd_en);
  input clk,rst,wr_en,rd_en;
  input [7:0]wr_data;
  output reg [7:0]rd_data;
  output reg empty,full; 
  
  reg [7:0]mem[7:0];
  reg [2:0]wraddr,rdaddr;
  reg [3:0]wrptr,rdptr;
  
  assign wraddr=wrptr[2:0];
  assign rdaddr=rdptr[2:0];
  
  assign empty = (wrptr == rdptr);
  assign full =((wrptr[3] != rdptr[3]) && (wrptr[2:0] == rdptr[2:0]));

  //Write Data logic 
  
  always@(posedge clk) begin 
    if(rst==1'b1) begin 
     
      for(int i=0;i<8;i=i+1)
        mem[i]<=0;
    end 
    else if(wr_en && !full)
      mem[wraddr]<=wr_data;
    
  end 
  
  //Read Data Logic 
  
  always@(posedge clk) begin
    if(rst==1'b1) begin
      rd_data<=0;
    end 
    
    else if(rd_en && !empty) 
      rd_data<=mem[rdaddr];
   
      
  end 
  //Write pointer logic 
  always@(posedge clk)
    begin
    if(rst)
      wrptr=4'b0000;
    else if(wr_en && !full)
      begin
        if(wrptr==8)
            begin
              wrptr[3]<=!wrptr[3];
            wrptr[2:0]<=wrptr[2:0];  
            end
           else 
             wrptr<=wrptr+1;
      end  
        else
          wrptr<=wrptr;
      end
    
  
    //Read pointer logic 
  always@(posedge clk) 
    begin
    if(rst)
      rdptr=4'b0000;
    else if(rd_en && !empty)
      begin
        if(rdptr==8)
          begin
            rdptr[3]<=!rdptr[3];
            rdptr[2:0]<=rdptr[2:0];
          end
        else
          rdptr<=rdptr+1;
          end
        else
          rdptr<=rdptr;
      end
    
endmodule
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  module tb;
  reg clk=1'b0,rst,wr_en,rd_en;
  reg [7:0]wr_data;
  wire empty,full;
  wire [7:0]rd_data;
  
  
  syncfifo DUT(.*);
  
  always #5 clk=~clk;
  
  initial begin
    rst=1'b0;
    
    #10 rst=1'b1;
    #20 rst=1'b0;
    
  end
  
  initial begin
    wr_en=1'b0;
    
    #30 wr_en=1'b1;
    #140 wr_en=1'b0;
  end
  initial begin
    rd_en=1'b0;
    #160 rd_en=1'b1;
  end
  
  
   
  initial begin 
    wr_data=0;
    @(posedge clk);
    @(posedge clk);
    
    repeat(9) begin
      @(posedge clk)
      wr_data=$urandom();
    end
  end 
  
  initial begin 
    $dumpfile("dump.vcd");
    $dumpvars();
    #400 $finish();
  end

  
endmodule  
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////



