module ALUSrcA(input wire PC, 
	           input wire memoria, 
	           input wire regA, 
               input wire [1:0] ALUSrcA, 
               output reg op1);
  
  always@(PC or memoria or regA or ALUSrcA) begin
        if (ALUSrcA == 2'b00) begin
            op1 = PC;
        end
      
        else if (ALUSrcA == 2'b01) begin
            op1 = memoria;
        end

        else if (ALUSrcA == 2'b10) begin
            op1 = regA;
        end

    end
      
endmodule