module mux3to1(input wire input00_0, 
	       input wire input01_1, 
	       input wire input10_2, 
               input wire [1:0] sel, 
               output reg out);
  
  always@(input00_0 or input01_1 or input10_2 or sel) begin
        if (sel == 2'b00) begin
            out = input00_0;
        end
      
        else if (sel == 2'b01) begin
            out = input01_1;
        end

        else if (sel == 2'b10) begin
            out = input10_2;
        end

    end
      
endmodule