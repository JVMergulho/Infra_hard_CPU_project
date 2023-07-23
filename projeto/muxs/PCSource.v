module PCSource(input wire jumpAdress, 
	            input wire ULA, 
	            input wire ALUout, 
                input wire [1:0] PCSource, 
                output reg out);
  
  always@(jumpAdress or ULA or ALUout or PCSource) begin
        if (PCSource == 2'b00) begin
            out = jumpAdress;
        end
      
        else if (PCSource == 2'b01) begin
            out = ULA;
        end

        else if (PCSource == 2'b10) begin
            out = ALUout;
        end

    end
      
endmodule