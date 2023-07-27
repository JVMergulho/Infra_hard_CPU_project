module sign_extend_8to32(input wire [7:0] input_data, 
                         output wire [31:0] output_data);

  // Expande os 8 bits de entrada para 32 bits adicionando 24 bits com o mesmo valor do bit de sinal
  assign output_data = (input_data[7]) ? {{8{1'b1}}, input_data} : {{8{1'b0}}, input_data};
  
end module
