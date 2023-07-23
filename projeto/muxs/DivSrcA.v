module DivSrcA(input wire [7:0] memoria, 
	       input wire [4:0] regA,
	       input wire DivSrcA,
	       output reg [7:0] op1);

  always@(memoria or regA or DivSrcA)begin
      if (DivSrcA == 1'b0) begin
        op1 = memoria;
      end

      else begin
        op1 = regA;
      end
    end
	
endmodule
