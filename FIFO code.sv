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
Final Asynchronous FIFO code with TB 
// Code your design here
module asyncfifo(wrclk,rdclk,wr_reset,rd_reset,wr_data,rd_data,empty,full,wr_en,rd_en);
  input wrclk,rdclk,wr_reset,rd_reset,wr_en,rd_en;
  input [7:0]wr_data;
  output reg [7:0]rd_data;
  output reg empty,full; 
  
  reg [7:0]mem[10];
  reg [3:0]wraddr,rdaddr;
  reg [4:0]wrptr,rdptr;
  
  reg almost_full,almost_empty;
  reg [3:0]no_of_bytes1,no_of_bytes2;
  reg [3:0]max_depth=10;
  reg [3:0]available_space;
  
  
  
  reg[4:0]sync1_wrptr,sync1_rdptr;
  reg[4:0]sync_wrptr,sync_rdptr;  
  
  assign wraddr=wrptr[3:0];
  assign rdaddr=rdptr[3:0];
  
  assign full=((wrptr[4]!=sync_rdptr[4])&&(wrptr[3:0]==sync_rdptr[3:0]))?1'b1:1'b0;
    
  assign empty=(rdptr[4:0]==sync_wrptr[4:0])?1'b1:1'b0;
  
  assign almost_full=(no_of_bytes1>=6) ? 1'b1:1'b0;
  assign almost_empty=(available_space>=6) ? 1'b1:1'b0;
 te Data logic 
  
  always@(posedge wrclk or negedge wr_reset) begin 
    if(wr_reset==1'b0) begin 
      wrptr[4:0]<=0;
      for(int i=0;i<10;i=i+1)
        mem[i]<=0;
    end 
    else if(wr_en && !full) begin 
      mem[wraddr]<=wr_data;
      
      if(wrptr==9)begin
        wrptr[4]<=~wrptr[4];
        wrptr[3:0]<=0;
      end
      else
        wrptr=wrptr+1;
    end 
    else 
      wrptr<=wrptr;
  end
  
  //Read Data Logic 
  
  always@(posedge rdclk or negedge rd_reset)begin
    if(rd_reset==1'b0) begin 
      rd_data[7:0]<=0;
      rdptr[4:0]<=0;
    end 
    
    else if(rd_en && !empty) begin
      rd_data<=mem[rdaddr];
      if(rdptr==9)begin
        rdptr[4]<=~rdptr[4];
        rdptr[3:0]<=0;
      end
        else
          rdptr<=rdptr+1;
    end
    else
      rdptr<=rdptr;
      
  end 
  
  //synchronizer logic for almost full condition
  
  always @(posedge wrclk or negedge wr_reset) begin
    if(wr_reset==0)
      no_of_bytes1<=0;
    else begin
      case({wrptr[4],sync_rdptr[4]})
        2'b00 : no_of_bytes1<=(wrptr-sync_rdptr);
        2'b01 : no_of_bytes1<=(max_depth-sync_rdptr+wrptr);
        2'b10 : no_of_bytes1<=(max_depth-sync_rdptr+wrptr);
        2'b11 : no_of_bytes1<=(wrptr-sync_rdptr);
      endcase
    end
  end
  
   //synchronizer logic for almost empty condition
  
  always @(posedge rdclk or negedge rd_reset) begin
    if(rd_reset==0)
      available_space<=0;
    else begin
      case({rdptr[4],sync_wrptr[4]})
        2'b00 : available_space<=(10-(sync_wrptr-rdptr));
        2'b01 : available_space<=(rdptr-sync_wrptr);
        2'b10 : available_space<=(rdptr-sync_wrptr);
        2'b11 : available_space<=(10-(sync_wrptr-rdptr));
      endcase
    end
  end
        
  
  //Synchronizer logic for sync_rdptr during full
  
  always @(posedge wrclk or negedge wr_reset) begin 
    if(wr_reset==1'b0) begin
   //  rdptr<=5'b0000;
      sync1_rdptr=0;
      sync_rdptr=0;
    end
    else begin 
      //rdptr_g_sync1=rdptr_b2g;
      //rdptr_g_sync2=rdptr_g_sync1;
      sync1_rdptr<=rdptr;
      sync_rdptr<=sync1_rdptr;
      
    end
  end 
  
   //Synchronizer logic for wr_rdptr during empty
  
  always @(posedge rdclk or negedge rd_reset) begin 
    if(rd_reset==1'b0) begin
    // wrptr=5'b0000;
      sync1_wrptr=0;
      sync_wrptr=0;
    end
    
    else begin 
      //wrptr_g_sync1=wrptr_b2g;
      //wrptr_g_sync2=wrptr_g_sync1;
      sync1_wrptr<=wrptr;
      sync_wrptr<=sync1_wrptr;
    end
  end
  
  
endmodule

interface intf(input logic clk,reset);
  
  logic wrclk;
  logic rdclk;
  logic wr_reset;
  logic rd_reset;
  logic [7:0]wr_data;
  logic [7:0]rd_data;
  logic empty;
  logic full;
  logic wr_en;
  logic rd_en;
  
endinterface
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
Completed TB of FIFO 
// Code your testbench here
// or browse Examples
`include "uvm_macros.svh"
import uvm_pkg::*;

class seq_item extends uvm_sequence_item;
  `uvm_object_utils(seq_item)
  
  function new(input string name="seq_item");
    super.new(name);
  endfunction
  
  rand logic[7:0]wr_data;
  rand logic wr_en,rd_en;
  logic [7:0]rd_data;
  logic empty,full; 
  logic wr_reset,rd_reset;
  
  constraint data{wr_data<100;}
  //constraint controlsignals{wr_en!=rd_en;}
  
endclass 

//////////////////////////////////////////////

class wr_seq extends uvm_sequence #(seq_item);
  `uvm_object_utils(wr_seq)
   seq_item ts;
  
  function new(input string name="wr_seq");
    super.new(name);
  endfunction 
  
  virtual task body();
    ts=seq_item::type_id::create("ts");
    
    repeat(10) begin 
    
      start_item(ts);
      ts.randomize() with {wr_en==1;rd_en==1'b0;};
      `uvm_info(get_type_name(),$sformatf("wrdata=%0d,wr_en=%0b,rd_en=%0b",ts.wr_data,ts.wr_en,ts.rd_en),UVM_NONE)
      finish_item(ts); 
    end
  endtask
endclass

//////////////////////////////////////////////////////

class rd_seq extends uvm_sequence #(seq_item);
  `uvm_object_utils(rd_seq)
  seq_item trd;
  function new(input string name="rd_seq");
    super.new(name);
  endfunction 
  
   virtual task body();
    trd=seq_item::type_id::create("trd");
    
     repeat(10) begin 
      start_item(trd);
       trd.randomize() with {rd_en==1'b1; wr_en==1'b0;};
      `uvm_info(get_type_name(),$sformatf("wrdata=%0d,wr_en=%0d,rd_en=%0d",trd.wr_data,trd.wr_en,trd.rd_en),UVM_NONE);
      finish_item(trd);
    end
      endtask
      
endclass

///////////////////////////////////////////////////

class driver extends uvm_driver #(seq_item);
  `uvm_component_utils(driver)
  
  virtual intf vif;
  seq_item td;
 
  
  function new(input string name="driver",uvm_component parent=null);
    super.new(name,parent);
  endfunction 
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    td=seq_item::type_id::create("td");
    if(!uvm_config_db #(virtual intf)::get(this,"","vif",vif))
      `uvm_info("DRV","Driver Unable to access interface",UVM_NONE);
  endfunction  
  
  virtual task run_phase(uvm_phase phase);
   super.run_phase(phase);
    reset();
   
    forever begin 
      seq_item_port.get_next_item(td);
     
      drive();
      `uvm_info(get_type_name(),$sformatf("reset=%0d,wrdata=%0d,wr_en=%0d,rd_en=%0d",vif.wr_reset,td.wr_data,td.wr_en,td.rd_en),UVM_NONE);
      seq_item_port.item_done();
       #10;
     end
   endtask
  
  task reset();
       vif.wr_reset<=1'b0;
       vif.rd_reset<=1'b0;
       vif.wr_data<=0;
       vif.wr_en<=1'b0;
       vif.rd_en<=1'b0;
      #5;
       vif.wr_reset<=1'b1;
       vif.rd_reset<=1'b1;
     
   
endtask 
    
    task drive();
      
      fork 
       begin 
         @(posedge vif.wrclk);
            vif.wr_en<=td.wr_en;
         if(td.wr_en && vif.wr_reset && !vif.full) begin
            vif.wr_data<=td.wr_data; 
          end
        end 
        
       begin 
         @(posedge vif.rdclk)
         vif.rd_en<=td.rd_en;
         /*if(td.rd_en && vif.rd_reset) begin
                 
           td.rd_data<=vif.rd_data;
          end*/
          end
      join_any
    endtask
endclass   
    
//////////////////////////////////////////////////

 class monitor extends uvm_monitor;
      `uvm_component_utils(monitor)
      uvm_analysis_port #(seq_item) wr_send;
      uvm_analysis_port #(seq_item) rd_send;
       seq_item tm;
       virtual intf vif;
      
      function new(input string name="monitor",uvm_component parent=null);
        super.new(name,parent);
        wr_send=new("wr_send",this);
        rd_send=new("rd_send",this);
      endfunction
      
    virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
      tm=seq_item::type_id::create("tm");
    if(!uvm_config_db #(virtual intf)::get(this,"","vif",vif))
    `uvm_fatal("MON","Unable to access interface");
  endfunction 
      
      virtual task run_phase(uvm_phase phase);
        super.run_phase(phase);
        #20;
      
        forever begin 
         
           fork
             begin 
               @(posedge vif.wrclk)
              if(vif.wr_en && vif.wr_reset && !vif.full) begin
               
                tm.wr_en=vif.wr_en;
                tm.full=vif.full;
               // tm.empty=vif.empty;
                tm.wr_data=vif.wr_data;
                
         
                wr_send.write(tm); `uvm_info(get_type_name(),$sformatf("wr_data=%0d,wr_en=%0b,rd_en=%0b,full=%0b",tm.wr_data,tm.wr_en,tm.rd_en,tm.full),UVM_NONE);
                end
           end
          
          begin 
            @(posedge vif.rdclk)
            if(vif.rd_en && vif.rd_reset && !vif.empty) begin
              
               tm.rd_en=vif.rd_en;
              #2
                tm.empty=vif.empty;
              
                tm.rd_data=vif.rd_data;
                
               // tm.full=vif.full;
                rd_send.write(tm);
              `uvm_info(get_type_name(),$sformatf("rd_data=%0d,wr_en=%0b,rd_en=%0b,full=%0b empty=%0b",tm.rd_data,tm.wr_en,tm.rd_en,tm.full,tm.empty),UVM_NONE);
          end
          end
          join_any
    end
endtask
endclass 

////////////////////////////////////////////////////////////////////////////////////////////////////
`uvm_analysis_imp_decl(_p1)
`uvm_analysis_imp_decl(_p2)

class scoreboard extends uvm_scoreboard;
  `uvm_component_utils(scoreboard)
  uvm_analysis_imp_p1 #(seq_item,scoreboard) p1;
  uvm_analysis_imp_p2 #(seq_item,scoreboard) p2;
  int wr_queue[$];
  int rd_queue[$];
  
  seq_item sb;
  seq_item sb1;

  
  function new(string path = "scoreboard",uvm_component p=null);
    super.new(path,p);
    p1=new("p1",this);
    p2=new("p2",this);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    sb=seq_item::type_id::create("sb",this);
    sb1=seq_item::type_id::create("sb1",this);
  endfunction
  
  ////////////recv1
  
  virtual function void write_p1(seq_item ts);
   sb=ts;
    
    wr_queue.push_back(sb.wr_data);
    
   
    `uvm_info("write_data",$sformatf("wr_data=%0p",wr_queue),UVM_NONE);
    
    
  endfunction
  
   ////////////recv2
  
  virtual function void write_p2(seq_item ts);
   sb1=ts;
    rd_queue.push_back(sb1.rd_data);
   `uvm_info("read_data",$sformatf("rd_data=%0p",rd_queue),UVM_NONE);
    if(rd_queue.size()==10)
      compare();
  endfunction 
  
  task compare;
    if(wr_queue.size==10 && rd_queue.size==10) begin 
      for(int i=0;i<10;i++) begin 
        if(wr_queue[i]==rd_queue[i]) begin
          `uvm_info("SCO",$sformatf("wr_data[%0d]=%0d rd_data[%0d]=%0d",i,wr_queue[i],i,rd_queue[i]),UVM_NONE)
       
          $display("TEST PASSED");
        end
        else begin 
           `uvm_info("SCO",$sformatf("wr_data[%0d]=%0d rd_data[%0d]=%0d",i,wr_queue[i],i,rd_queue[i]),UVM_NONE)
       
          $display("TEST FAILED");
        end
        end
    end
  endtask
  

endclass



////////////////////////////////////////////////////

class agent extends uvm_agent;
            `uvm_component_utils(agent)
            
            function new(input string name="agent",uvm_component parent=null);
              super.new(name,parent);
            endfunction
            
            driver d;
            monitor m;
            uvm_sequencer #(seq_item)sq;
            
            virtual function void build_phase(uvm_phase phase);
              super.build_phase(phase);
              d=driver::type_id::create("d",this);
              m=monitor::type_id::create("m",this);
              sq=uvm_sequencer #(seq_item)::type_id::create("sq",this);
            endfunction
            
            virtual function void connect_phase(uvm_phase phase);
             super.connect_phase(phase);
             
              d.seq_item_port.connect(sq.seq_item_export);
             
              endfunction
        endclass 

///////////////////////////////////////////////////

class env extends uvm_env;
        `uvm_component_utils(env)
       agent a;
       scoreboard s;
       function new(input string name="env",uvm_component parent=null);
         super.new(name,parent);
            endfunction
       
           virtual function void build_phase(uvm_phase phase);
            super.build_phase(phase);
          
             a=agent::type_id::create("a",this);
             s=scoreboard::type_id::create("s",this);
            endfunction
       
       virtual function void connect_phase(uvm_phase phase);
         super.connect_phase(phase);
         a.m.wr_send.connect(s.p1);
         a.m.rd_send.connect(s.p2);
       endfunction
            
       endclass 

/////////////////////////////////////////////////

class test extends uvm_test;
    `uvm_component_utils(test)
            
    function new(input string name="test",uvm_component parent=null);
              super.new(name,parent);
           endfunction
            
            wr_seq wr_s;
            rd_seq rd_s;
            env e;
            virtual function void build_phase(uvm_phase phase);
            super.build_phase(phase);
              
              wr_s=wr_seq::type_id::create("wr_s",this);
             
              rd_s=rd_seq::type_id::create("rd_s",this);
              e=env::type_id::create("e",this);
              
            endfunction  
            
            virtual task run_phase(uvm_phase phase);
             super.run_phase(phase);
              phase.raise_objection(this);
               
              wr_s.start(e.a.sq);
              
            #10;
              rd_s.start(e.a.sq); 
              #30;
              phase.drop_objection(this);
              
            endtask
            
          endclass 

///////////////////////////////////////////////////

import uvm_pkg::*;
`include "uvm_macros.svh"

module tb;
 intf vif();
 asyncfifo dut(.wrclk(vif.wrclk),.rdclk(vif.rdclk),.wr_reset(vif.wr_reset),.rd_reset(vif.rd_reset),.wr_data(vif.wr_data),.rd_data(vif.rd_data),.empty(vif.empty),.full(vif.full),.wr_en(vif.wr_en),.rd_en(vif.rd_en));  
            
            always #10 vif.wrclk=~vif.wrclk;
            always #10 vif.rdclk=~vif.rdclk;
            
             initial begin 
               uvm_config_db #(virtual intf)::set(null,"*","vif",vif);
               run_test("test");
             end
            
            
              initial begin 
              vif.rdclk=1'b0;
              vif.wrclk=1'b0;
            end 
            
            initial begin 
              $dumpfile("dump.vcd");
              $dumpvars();
            end           
          endmodule

/*
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
    #5 rd_reset=1'b1;
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
    @(posedge wrclk);
    @(posedge wrclk);
    
    repeat(12) begin
      @(posedge wrclk)
      wr_data=$urandom();
    end
  end 
  
  initial begin 
    $dumpfile("dump.vcd");
    $dumpvars();
    #400 $finish();
  end

  
endmodule  
*/


