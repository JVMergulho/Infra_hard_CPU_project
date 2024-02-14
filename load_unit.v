module load_unit (
  input wire [31:0] mem_in, 
  input wire [1:0] LoadCtrl,
  output wire [31:0] data_out
);

  assign data_out = (LoadCtrl == 2'b01) ? mem_in : (LoadCtrl == 2'b10) ? {{16{1'b0}},mem_in[15:0]} : {{23{1'b0}},mem_in[7:0]};

endmodule