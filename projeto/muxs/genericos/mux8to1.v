module mux8to1(input wire input000_0, 
               input wire input001_1, 
               input wire input010_2, 
               input wire input011_3, 
               input wire input100_4, 
               input wire input101_5, 
               input wire input110_6, 
               input wire input111_7,
               input wire [2:0] sel, 
               output reg out);
  
  always@(input000_0 or input001_1 or input010_2 or input011_3 or input100_4 or input101_5 or input110_6 or input111_7 or sel) begin
        if (sel == 3'b000) begin
            out = input000_0;
        end
      
        else if (sel == 3'b001) begin
            out = input001_1;
        end

        else if (sel == 3'b010) begin
            out = input010_2;
        end

        else if (sel == 3'b011) begin
            out = input011_3;
        end

        else if (sel == 3'b100) begin
            out = input100_4;
        end

        else if (sel == 3'b101) begin
            out = input101_5;
        end

        else if (sel == 3'b110) begin
            out = input110_6;
        end

        else begin
            out = input111_7;
        end

    end
      
endmodule