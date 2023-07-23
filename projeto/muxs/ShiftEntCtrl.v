module ShiftEntCtrl(input wire imediato, 
	       	    input wire regB, 
	      	    input wire regA, 
              	    input wire [1:0] ShiftEntCtrl, 
             	    output reg ent32);
  
  always@(imediato or regB or regA or ShiftEntCtrl) begin
        if (ShiftEntCtrl == 2'b00) begin
            ent32 = imediato;
        end
      
        else if (ShiftEntCtrl == 2'b01) begin
            ent32 = regB;
        end

        else if (ShiftEntCtrl == 2'b10) begin
            ent32 = regA;
        end

    end
      
endmodule