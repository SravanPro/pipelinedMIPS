`timescale 1ns / 1ps


module regFile(
    input clock, reset, regWrite,
    
    input [4:0] rn1,
    input [4:0] rn2,
    input [4:0] wn,
    
    input [31:0] wd,
    
    output [31:0] rd1,
    output [31:0] rd2 
);

     reg [31:0] regBank [31:0];
     reg [7:0] i;
     
     assign rd1 = regBank[rn1];
     assign rd2 = regBank[rn2];
     
     always @(posedge clock or posedge reset) begin
     
        if(reset) begin
            for(i = 0; i<32; i = i+1) begin
                regBank[i] <= 32'd0;
            end
        end
        
        else begin
            if(regWrite && wn != 5'd0) begin
                regBank[wn] <= wd;
            end
        end
     end     
endmodule
