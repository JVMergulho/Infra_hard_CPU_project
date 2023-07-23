module EntWrite(input wire ALUout, 
               input wire ShiftOut, 
               input wire high, 
               input wire low, 
               input wire load, 
               input wire PC, 
               input wire bitSLT,
               input wire [2:0] EntWrite, 
               output reg out);
  
  always@(ALUout or ShiftOut or high or low or load or PC or bitSLT or EntWrite) begin
        if (EntWrite == 3'b000) begin
            out = ALUout;
        end
      
        else if (EntWrite == 3'b001) begin
            out = ShiftOut;
        end

        else if (EntWrite == 3'b010) begin
            out = high;
        end

        else if (EntWrite == 3'b011) begin
            out = low;
        end

        else if (EntWrite == 3'b100) begin
            out = 8'd227;
        end

        else if (EntWrite == 3'b101) begin
            out = load;
        end

        else if (EntWrite == 3'b110) begin
            out = PC;
        end

        else begin
            out = bitSLT;
        end

    end
      
endmodule