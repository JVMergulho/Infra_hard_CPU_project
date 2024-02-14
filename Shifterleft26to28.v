module Shifterleft26to28(
    input wire [25:0] word26,
    output wire [27:0] word28
);

    // Shifter left to 28 bits, adds to '00' to the right.
  assign word28 = {word26, 2'b00};


endmodule