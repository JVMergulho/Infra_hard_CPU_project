module MemReadCtrl(input wire PC, 
                   input wire ALUout, 
                   input wire regB, 
                   input wire [2:0] MemReadCtrl, 
                   output reg out);
  
  always@(PC or ALUout or regB or MemReadCtrl) begin
        if (MemReadCtrl == 3'b000) begin
            out = PC;
        end
      
        else if (MemReadCtrl == 3'b001) begin
            out = 8'd253;
        end

        else if (MemReadCtrl == 3'b010) begin
            out = 8'd254;
        end

        else if (MemReadCtrl == 3'b011) begin
            out = 8'd255;
        end

        else if (MemReadCtrl == 3'b100) begin
            out = ALUout;
        end

        else begin
            out = regB;
        end

    end
      
endmodule