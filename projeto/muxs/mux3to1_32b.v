//mux 3 to 1 - 32 bits inputs e output e 2 bits sel
//PCCtrl
//ShiftEntCtrl
//PCSource
//ALUSrcA

module mux3to1_32b(input wire [31:0] input00_0, 
	           input wire [31:0] input01_1, 
	           input wire [31:0] input10_2, 
                   input wire [1:0] sel, 
                   output reg [31:0] out);
  
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
