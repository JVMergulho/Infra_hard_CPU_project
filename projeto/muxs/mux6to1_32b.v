//mux 6 to 1 - 32 bits inputs e output e 3 bits sel
//MemReadCtrl

module mux6to1_32b(input wire [31:0] input000_0, 
                   input wire [31:0] input001_1, 
                   input wire [31:0] input010_2, 
                   input wire [31:0] input011_3, 
                   input wire [31:0] input100_4, 
                   input wire [31:0] input101_5, 
                   input wire [2:0] sel, 
                   output reg [31:0] out);
  
  assign out = (sel == 3'b000) ? input000_0 : 
               (sel == 3'b001) ? input001_1 :
               (sel == 3'b010) ? input010_2 :
               (sel == 3'b011) ? input011_3 :
	       (sel == 3'b100) ? input100_4 :
               (sel == 3'b101) ? input101_5 :
               32'bXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX;
      
endmodule
