module ShiftShiftCtrl(input wire regB, 
	                  input wire shamt,  
                      input wire [1:0] ShiftShiftCtrl, 
                      output reg ent5);

  
  always@(regB or shamt or ShiftShiftCtrl) begin
        if (ShiftShiftCtrl == 2'b00) begin
            ent5 = regB;
        end
      
        else if (ShiftShiftCtrl == 2'b01) begin
            ent5 = shamt;
        end

        else if (ShiftShiftCtrl == 2'b10) begin
            ent5 = 5'b10000;
        end

    end
      
endmodule