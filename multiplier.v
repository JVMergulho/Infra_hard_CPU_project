module multiplier (input wire clk, reset, start,
            input wire [31:0] A, B,
            output reg [31:0] Hi, Lo
);

  reg [31:0] Q; // multiplier
  reg [31:0] Acc; // accumulator
  reg Q_minus; // aux bit
  reg [5:0] counter;
  reg [31:0] Complemento_A;

  always @(posedge clk) begin
    
    if (reset == 1'b1 || start == 1'b1) begin
      Q = B; //Q recebe multiplicando
      Acc = 32'd0;
      Q_minus = 1'b0;
      counter = 6'd32;
      Complemento_A = ~A + 1;

      Hi = 32'd0;
      Lo = 32'd0;
      
    end else if (counter != 6'd0) begin
  
      if (Q[0] == 1'b0 && Q_minus == 1'b1) begin
        Acc = Acc + A;
        
      end
  
      else if (Q[0] == 1'b1 && Q_minus == 1'b0) begin
        Acc = Acc + Complemento_A; // complemento de A + 1
        
      end

      {Acc,Q,Q_minus} = {Acc,Q,Q_minus} >>> 1'b1;
      if (Acc[30] == 1'b1) begin // correcao do shift right
		    Acc[31] = 1'b1;
		  end
  
      counter = counter - 6'd1;

      if (counter == 6'd0) begin 
        if (Acc == 32'b11111111111111111111111111111111) begin
          Acc = 32'b00000000000000000000000000000000;
        end
         
        Hi = Acc;
        Lo = Q;
      end
    end
  end 
endmodule