//mux 4 to 1 - 32 bits inputs e outputs e 2 bits sel
//ALUSrcB

module mux4to1_32b(input wire [31:0] input00_0, 
                   input wire [31:0] input01_1, 
                   input wire [31:0] input10_2, 
                   input wire [31:0] input11_3, 
                   input wire [1:0] sel, 
                   output wire [31:0] out);
  
  assign out = (sel == 2'b00) ? input00_0 : 
               (sel == 2'b01) ? input01_1 :
               (sel == 2'b10) ? input10_2 :
               (sel == 2'b11) ? input11_3 :
               32'bXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX;
      
endmodule