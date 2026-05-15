`timescale 1ns / 1ps

// Main Control - decodes 6-bit opcode into control signals
// ALUOp is now 4 bits:
//   4'b0000 = ADD  (lw/sw)
//   4'b0001 = SUB  (beq)
//   4'b0010 = R-type (aluControl decodes funct)
//   4'b0011 = SLT-immediate (custom, reserved)

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
        // defaults (safe NOP state)
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
            6'b000000: begin // R-format
                regDst   = 1'b1;
                regWrite = 1'b1;
                aluOp    = 4'b0010;
            end

            6'b100011: begin // lw
                aluSrc   = 1'b1;
                memToReg = 1'b1;
                regWrite = 1'b1;
                memRead  = 1'b1;
                aluOp    = 4'b0000;
            end

            6'b101011: begin // sw
                aluSrc   = 1'b1;
                memWrite = 1'b1;
                aluOp    = 4'b0000;
            end
             
            6'b000100: begin // beq
                branchEq = 1'b1;
                aluOp    = 4'b0001;
            end
            6'b000101: begin // bne
                branchNe = 1'b1;
                aluOp    = 4'b0001;  // still SUB to check equality
            end

            6'b000010: begin // j (jump)
                jump     = 1'b1;
            end

            // ── extras you can add ────────────────────────────
            6'b001010: begin // slti
                aluSrc   = 1'b1;
                regWrite = 1'b1;
                aluOp    = 4'b0011;
            end
         
         
            6'b001000: begin // addi
                aluSrc   = 1'b1;
                regWrite = 1'b1;
                aluOp    = 4'b0000;
            end     
            

            default: begin
                // all zeros = NOP / bubble
            end
        endcase
    end
endmodule