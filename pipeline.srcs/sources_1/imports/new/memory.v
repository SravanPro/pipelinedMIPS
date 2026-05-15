`timescale 1ns / 1ps


module memory #(parameter memorySizeInBytes = 128) // 32 locations sized 32bit

(
    input clock, reset,
    input memWrite, memRead,
    input [31:0] address,
    input [31:0] writeData,
    output [31:0] readData
    
);

    integer i;
    reg [7:0] mem [memorySizeInBytes-1 : 0];
    
    
    // just initializing the meemory to random values, dont care.
    initial begin
            for(i = 0; i<memorySizeInBytes; i = i+1) begin
                if(i[1:0] == 2'b11) mem[i] = (i+1)/4;
                else mem[i]= 0;
            end
    end
    
    
    assign readData = 
    memRead ? {mem[address], mem[address + 1], mem[address + 2], mem[address + 3]} : 32'd0;
  
    always @(posedge clock or posedge reset) begin
    
        if(reset) begin
            for(i = 0; i<memorySizeInBytes; i = i+1) begin
                if(i[1:0] == 2'b11) mem[i] <= (i+1)/4;
                else mem[i]<= 0;
            end
                          
        end
        
        else begin
            if(memWrite) begin
                mem[address]     <= writeData[31:24];
                mem[address + 1] <= writeData[23:16];
                mem[address + 2] <= writeData[15: 8];
                mem[address + 3] <= writeData[ 7: 0];          
            end
        end
    end
    
endmodule
