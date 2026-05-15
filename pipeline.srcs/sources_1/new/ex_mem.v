`timescale 1ns / 1ps

// EX/MEM Pipeline Register
// EX control signals (RegDst, ALUSrc, ALUOp) consumed in EX - NOT passed.
// Branch is consumed HERE at MEM stage: PCSrc = Branch AND Zero.
// Passes: WB control signals + datapath results to MEM/WB.

module ex_mem (
    input  wire        clk,
    input  wire        reset,

    // ── Datapath inputs ───────────────────────────────────────────
    input  wire [31:0] ex_mem_BranchTarget_in, // branch target PC
    input  wire        ex_mem_Zero_in,          // ALU zero flag (for beq)
    input  wire [31:0] ex_mem_AluOut_in,        // ALU result
    input  wire [31:0] ex_mem_B_in,             // RegFile RD2 (for sw)
    input  wire [4:0]  ex_mem_RegDest_in,       // destination register (after RegDst mux)

    // ── MEM-stage control inputs ──────────────────────────────────
    input  wire        ex_mem_BranchEq_in,
    input  wire        ex_mem_BranchNe_in,
    input  wire        ex_mem_MemRead_in,
    input  wire        ex_mem_MemWrite_in,

    // ── WB-stage control inputs ───────────────────────────────────
    input  wire        ex_mem_RegWrite_in,
    input  wire        ex_mem_MemToReg_in,

    // ── Datapath outputs ──────────────────────────────────────────
    output reg  [31:0] ex_mem_BranchTarget_out,
    output reg         ex_mem_Zero_out,
    output reg  [31:0] ex_mem_AluOut_out,
    output reg  [31:0] ex_mem_B_out,
    output reg  [4:0]  ex_mem_RegDest_out,

    // ── MEM-stage control outputs ─────────────────────────────────
    output reg         ex_mem_BranchEq_out,
    output reg         ex_mem_BranchNe_out,
    output reg         ex_mem_MemRead_out,
    output reg         ex_mem_MemWrite_out,

    // ── WB-stage control outputs ──────────────────────────────────
    output reg         ex_mem_RegWrite_out,
    output reg         ex_mem_MemToReg_out
);

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            ex_mem_BranchTarget_out <= 32'b0;
            ex_mem_Zero_out         <= 1'b0;
            ex_mem_AluOut_out       <= 32'b0;
            ex_mem_B_out            <= 32'b0;
            ex_mem_RegDest_out      <= 5'b0;

            ex_mem_BranchEq_out       <= 1'b0;
            ex_mem_BranchNe_out       <= 1'b0;
            ex_mem_MemRead_out      <= 1'b0;
            ex_mem_MemWrite_out     <= 1'b0;

            ex_mem_RegWrite_out     <= 1'b0;
            ex_mem_MemToReg_out     <= 1'b0;
        end
        else begin
            ex_mem_BranchTarget_out <= ex_mem_BranchTarget_in;
            ex_mem_Zero_out         <= ex_mem_Zero_in;
            ex_mem_AluOut_out       <= ex_mem_AluOut_in;
            ex_mem_B_out            <= ex_mem_B_in;
            ex_mem_RegDest_out      <= ex_mem_RegDest_in;

            ex_mem_BranchEq_out       <= ex_mem_BranchEq_in;
            ex_mem_BranchNe_out       <= ex_mem_BranchNe_in;
            ex_mem_MemRead_out      <= ex_mem_MemRead_in;
            ex_mem_MemWrite_out     <= ex_mem_MemWrite_in;

            ex_mem_RegWrite_out     <= ex_mem_RegWrite_in;
            ex_mem_MemToReg_out     <= ex_mem_MemToReg_in;
        end
    end
endmodule