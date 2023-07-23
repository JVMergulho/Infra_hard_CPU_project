module PCCtrl(input wire EPC, 
	      input wire ALUout, 
	      input wire excecao, 
              input wire [1:0] PCCtrl, 
              output reg PC);
  
  always@(EPC or ALUout or excecao or PCCtrl) begin
        if (PCCtrl == 2'b00) begin
            PC = EPC;
        end
      
        else if (PCCtrl == 2'b01) begin
            PC = ALUout;
        end

        else if (PCCtrl == 2'b10) begin
            PC = excecao;
        end

    end
      
endmodule