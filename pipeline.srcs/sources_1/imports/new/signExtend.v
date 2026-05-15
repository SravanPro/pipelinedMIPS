`timescale 1ns / 1ps

module signExtend(
    input [15:0] in,
    output [31:0] out
);
    // This replicates the sign bit (in[15]) 16 times
    assign out = {{16{in[15]}}, in}; 
endmodule
