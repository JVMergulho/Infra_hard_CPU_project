//mux de 2 para 1 - 32 bits inputs e 1 bit sel 
//DivSrcA
//DivSrcB
//HiCtrl
//LoCtrl


module mux2to1_32b(input wire [31:0] input0, 
		               input wire [31:0] input1,
		               input wire sel, 
               	   output wire [31:0] out);
  
  assign out = (sel == 1'b0) ? input0 :
	             (sel == 1'b1) ? input1 : 
	             1'bX;
      
endmodule