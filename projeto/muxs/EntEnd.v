module EntEnd(input wire RT, 
              input wire RD, 
              input wire [1:0] EntEnd, 
              output reg entRegDest);
  
  always@(RT or RD or EntEnd) begin
        if (EntEnd == 2'b00) begin
            entRegDest = RT;
        end
      
        else if (EntEnd == 2'b01) begin
            entRegDest = RD;
        end

        else if (EntEnd == 2'b10) begin
            entRegDest = 5'b11111;
        end

        else begin
            entRegDest = 5'b11101;
        end

    end
      
endmodule