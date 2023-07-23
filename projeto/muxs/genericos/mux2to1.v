module mux2to1(input wire input0, input1, sel, 
               output reg out);
  
  always@(input0 or input1 or sel)begin
      if (sel == 1'b0)
      begin
        out = input0;
      end
      else 
      begin
        out = input1;
      end
    end
      
endmodule
