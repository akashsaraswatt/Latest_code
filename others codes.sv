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
