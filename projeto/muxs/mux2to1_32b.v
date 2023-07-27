//mux de 2 para 1 - 32 bits inputs e 1 bit sel 
//DivSrcA
//DivSrcB
//HiCtrl
//LoCtrl
module mux2to1_32b(input wire [31:0] input0, 
		               input wire [31:0] input1,
		               input wire sel, 
               	   output reg [31:0] out);
  
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
