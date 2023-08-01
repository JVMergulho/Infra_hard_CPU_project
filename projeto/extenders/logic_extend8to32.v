module logic_extend_8to32(input wire [7:0] input_data,
                          output wire [31:0] output_data);

  // Expande os 8 bits de entrada para 32 bits adicionando 24 bits com o valor 0
  assign output_data = {{24{1'b0}}, data_1};;

endmodule 
