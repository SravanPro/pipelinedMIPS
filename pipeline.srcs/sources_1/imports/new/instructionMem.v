`timescale 1ns / 1ps


module instructionMem #(parameter instructionMemSizeInBytes = 1024)

(
    input [31:0] pcVal,
    output [31:0] instruction
);
    reg [7:0] i;
    reg [7:0] mem [instructionMemSizeInBytes-1 : 0];
    assign instruction = {mem[pcVal], mem[pcVal + 1], mem[pcVal + 2], mem[pcVal + 3]};
    
endmodule
