module logic_extend_1to32(input wire input_data,
                          output wire [31:0] output_data);

  // Expande o único bit de entrada para 32 bits adicionando 31 bits com o valor 0
  assign output_data ={{31'b0}, input_data};
  
endmodule
