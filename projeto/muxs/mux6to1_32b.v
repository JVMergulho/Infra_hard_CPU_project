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
  
  always@(input000_0 or input001_1 or input010_2 or input011_3 or input100_4 or input101_5 or sel) begin
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

        else begin
            out = input101_5;
        end

    end
      
endmodule
