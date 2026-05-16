`timescale 1ns / 1ps

module mainControl(
    input      [5:0] opCode,

    output reg       regDst,
    output reg       aluSrc,
    output reg       memToReg,
    output reg       regWrite,
    output reg       memRead,
    output reg       memWrite,
    output reg       branchEq,
    output reg       branchNe,
    output reg       jump,
    output reg [3:0] aluOp
);

    always @(*) begin

        regDst   = 1'b0;
        aluSrc   = 1'b0;
        memToReg = 1'b0;
        regWrite = 1'b0;
        memRead  = 1'b0;
        memWrite = 1'b0;
        
        branchEq   = 1'b0;
        branchNe   = 1'b0;
        
        jump     = 1'b0;
        aluOp    = 4'b0000;

        case (opCode)
            6'b000000: begin
                regDst   = 1'b1;
                regWrite = 1'b1;
                aluOp    = 4'b0010;
            end

            6'b100011: begin
                aluSrc   = 1'b1;
                memToReg = 1'b1;
                regWrite = 1'b1;
                memRead  = 1'b1;
                aluOp    = 4'b0000;
            end

            6'b101011: begin
                aluSrc   = 1'b1;
                memWrite = 1'b1;
                aluOp    = 4'b0000;
            end
             
            6'b000100: begin
                branchEq = 1'b1;
                aluOp    = 4'b0001;
            end
            6'b000101: begin
                branchNe = 1'b1;
                aluOp    = 4'b0001;
            end

            6'b000010: begin
                jump     = 1'b1;
            end


            6'b001010: begin
                aluSrc   = 1'b1;
                regWrite = 1'b1;
                aluOp    = 4'b0011;
            end
         
         
            6'b001000: begin
                aluSrc   = 1'b1;
                regWrite = 1'b1;
                aluOp    = 4'b0000;
            end     
            

            default: begin

            end
        endcase
    end
endmodule
