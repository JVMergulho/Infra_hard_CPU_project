module divider (
  input wire clk, reset, start,
  input wire [31:0] dividendo,
  input wire [31:0] divisor,
  output reg divzero,
  output reg [31:0] Hi, Lo
);

  reg [63:0] div; /// ----> nas implementações de outros grupos aqui é 32 bits
  reg [63:0] resto; // aqui tbm
  reg [31:0] quociente;
  reg [5:0] counter;

  always @(posedge clk) begin
    if (reset == 1'b1 || start == 1'b1) begin
      if (divisor == 32'd0) begin // verifica se o divisor é 0
        divzero = 1'b1;
        end 
      else begin

        if (dividendo[31] == 1'b1) begin
          resto[31:0] = ~dividendo + 1'b1; // se for negativo inverte o sinal (complemento de 2)
        end else begin
          resto[31:0] = dividendo;
        end
  
        if (divisor[31] == 1'b1) begin
          div[63:32] = ~divisor + 1'b1; // se for negativo inverte o sinal (complemento de 2)
        end else begin
          div[63:32] = divisor;
        end

        div[31:0] = 32'd0;
        resto[63:32] = 32'd0;
        quociente = 32'd0;
        Hi = 32'd0;
        Lo = 32'd0;
        divzero = 1'b0;
        counter = 6'd33;
        
      end
      
    end else// fim do reset/start
      if (divzero != 1'b1 && counter != 6'd0) begin
        resto = resto - div;
        
        if (resto[63] == 1'b1) begin
          resto = resto + div;
          quociente = quociente << 1'b1;
          quociente[0] = 1'b0;
        end else begin
          quociente = quociente << 1'b1;
          quociente[0] = 1'b1;
        end

        div = div >> 1'b1;

        counter = counter - 6'd1;

        if (counter == 6'd0) begin // ajuste de sinal
          if (divisor[31] != dividendo[31]) begin // divisor e quociente de sinais opostos
            if (divisor[31] == 1'b1) begin // divisor neg
              
              // dividendo pos, divisor neg, quociente neg, resto pos
              Hi = resto[31:0];
              Lo = ~quociente + 1'b1; 
            end else begin // dividendo neg
              
              // dividendo neg, divisor pos, quociente neg, resto neg
              Hi = ~resto[31:0] + 1'b1; 
              Lo = ~quociente + 1'b1; 
            end
          end else
            if (divisor[31] == 1'b1) begin // divisor e dividendo neg
              
              // dividendo neg, divisor neg, quociente pos, resto neg
              Hi = ~resto[31:0] + 1'b1;
              Lo = quociente;
          end else begin 
            // divisor pos, dividendo pos, quociente pos, resto pos
            Hi = resto[31:0];
            Lo = quociente;
        end
      end
    end
  end
endmodule