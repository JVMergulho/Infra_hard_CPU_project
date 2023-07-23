module DivSrcB(input wire [4:0] regB, 
	       input wire [7:0] memoria,
	       input wire DivSrcB, 
               output reg [7:0] op2);
  
  always@(regB or memoria or DivSrcB)begin
      if (DivSrcB == 1'b0)
      begin
        op2 = regB;
      end

      else begin
        op2 = memoria;
      end
    end
      
endmodule