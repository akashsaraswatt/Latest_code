class main;
  rand int length;
  rand logic [31:0] que[$];
  
  constraint c1 { length inside {[1:100]}; }
  constraint c2 { que.size() == length;
                  foreach (que[i])
                    que[i] inside {[1:100]}; }
  constraint c3 { que.sum() == 1500; }
  
  function void print();
    $display("the value of length=%0d", length);
    $display("queue size is =%0d", que.size);
    //foreach(que[i])
    $display("values of queue=%0p ", que);
    $display("queue sum is =%0d", que.sum);
  endfunction
endclass

module test;
  main m;
  initial begin
    m = new();
    if (!m.randomize()) // Check if randomization fails
      $display("Randomization failed");
    m.print();
  end
endmodule
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
# KERNEL: the value of length=41
# KERNEL: queue size is =41
# KERNEL: values of queue=12 3 8 6 7 29 5 7 5 1 2 1 1 1 1 1 1 53 60 99 89 95 17 2 16 3 6 1 34 12 81 3 64 96 99 100 80 100 99 100 100 
# KERNEL: queue sum is =1500
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
class main;
  rand int length;
  rand logic [31:0] que[$];
  
  constraint c1 { length inside {[50:100]}; }
  constraint c2 { que.size() == length;
                  foreach (que[i])
                    que[i] inside {[1:100]}; }
  constraint c3 { que.sum() == 1500; }
  
  function void post_randomize();
    $display("the value of length=%0d", length);
    $display("queue size is =%0d", que.size);
    $display("values of queue=%0p ", que);
    $display("queue sum is =%0d", que.sum);
  endfunction
endclass

module test;
  main m;
  initial begin
    m = new();
    if (!m.randomize()) // Check if randomization fails
      $display("Randomization failed");
    
  end
endmodule
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
# KERNEL: the value of length=53
# KERNEL: queue size is =53
# KERNEL: values of queue=72 20 1 1 1 2 7 54 15 19 3 2 15 73 91 100 14 49 27 96 79 35 60 49 89 25 6 21 16 13 6 10 3 2 2 1 2 6 15 8 5 63 26 81 58 64 1 1 2 2 65 16 6 
# KERNEL: queue sum is =1500
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
