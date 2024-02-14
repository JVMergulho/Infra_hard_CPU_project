module store_unit (
  input wire [31:0] mem_in, 
  input wire [31:0]  B_in,
  input wire [1:0] StoreCtrl,
  output wire [31:0] data_out
);

  assign data_out = (StoreCtrl == 2'b01) ? B_in : (StoreCtrl == 2'b10) ? {mem_in[31:16],B_in[15:0]} : {mem_in[31:8],B_in[7:0]};

endmodule