module ALUSrcB(input wire regB, 
               input wire branchAdress, 
               input wire imediato, 
               input wire [1:0] ALUSrcB, 
               output reg op2);
  
  always@(regB or branchAdress or imediato or ALUSrcB) begin
        if (ALUSrcB == 2'b00) begin
            op2 = regB;
        end
      
        else if (ALUSrcB == 2'b01) begin
            op2 = 5'b00101;
        end

        else if (ALUSrcB == 2'b10) begin
            op2 = branchAdress;
        end

        else begin
            op2 = imediato;
        end

    end
      
endmodule