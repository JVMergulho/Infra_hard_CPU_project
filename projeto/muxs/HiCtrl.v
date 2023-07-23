module HiCtrl(input wire div,
	      input wire mult, 
	      input wire HiCtrl, 
              output reg high);
  
  always@(div or mult or HiCtrl)begin
      if (HiCtrl == 1'b0) begin
        high = div;
      end

      else begin
        high = mult;
      end
    end
      
endmodule