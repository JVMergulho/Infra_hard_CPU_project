module LoCtrl(input wire div,
	      input wire mult, 
	      input wire LoCtrl, 
              output reg low);
  
  always@(div or mult or LoCtrl)begin
      if (LoCtrl == 1'b0) begin
        low = div;
      end

      else begin
        low = mult;
      end
    end
      
endmodule