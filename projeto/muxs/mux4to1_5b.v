module mux4to1_5b(input wire [4:0] input00_0, 
                  input wire [4:0] input01_1, 
       	          input wire [4:0] input10_2, 
                  input wire [4:0] input11_3, 
                  input wire [1:0] sel, 
                  output reg [4:0] out);
  
  always@(input00_0 or input01_1 or input10_2 or input11_3 or sel) begin
        if (sel == 2'b00) begin
            out = input00_0;
        end
      
        else if (sel == 2'b01) begin
            out = input01_1;
        end

        else if (sel == 2'b10) begin
            out = input10_2;
        end

        else begin
            out = input11_3;
        end

    end
      
endmodule