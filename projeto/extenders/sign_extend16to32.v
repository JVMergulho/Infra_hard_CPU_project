module sign_extend_16to32(input wire [15:0] input_data, 
                         output wire [31:0] output_data);

  // Expande os 16 bits de entrada para 32 bits adicionando 16 bits com o mesmo valor do bit de sinal
  assign output_data = (input_data[15]) ? {{16{1'b1}}, input_data} : {{16{1'b0}}, input_data};
  
endmodule
