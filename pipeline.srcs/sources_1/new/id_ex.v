`timescale 1ns / 1ps

// ID/EX Pipeline Register
// Branch decision is made at MEM stage, so Branch passes through ID/EX and EX/MEM.
// Jump is consumed in ID (PC mux), so it is NOT passed through.
// Stall zeroes all control signals to insert a bubble (NOP).

module id_ex (
    input  wire        clk,
    input  wire        reset,
    input  wire        id_ex_stall,      // 1 = insert bubble (load-use stall)

    // ── Datapath inputs ──────────────────────────────────────────
    input  wire [31:0] id_ex_NPC_in,
    input  wire [31:0] id_ex_A_in,        // RegFile read data 1
    input  wire [31:0] id_ex_B_in,        // RegFile read data 2
    input  wire [31:0] id_ex_Imm_in,      // sign-extended immediate
    input  wire [4:0]  id_ex_RS_in,       // Rs number  (for forwarding)
    input  wire [4:0]  id_ex_RT_in,       // Rt number  (for forwarding + RegDst mux)
    input  wire [4:0]  id_ex_RD_in,       // Rd number  (for RegDst mux)

    // ── EX-stage control inputs ───────────────────────────────────
    input  wire        id_ex_RegDst_in,   // 0=Rt is dest, 1=Rd is dest
    input  wire        id_ex_ALUSrc_in,   // 0=RegB, 1=Imm
    input  wire [3:0]  id_ex_ALUOp_in,    // 4-bit ALU operation selector

    // ── MEM-stage control inputs ──────────────────────────────────
    input  wire        id_ex_BranchEq_in,
    input  wire        id_ex_BranchNe_in,

    input  wire        id_ex_MemRead_in,
    input  wire        id_ex_MemWrite_in,

    // ── WB-stage control inputs ───────────────────────────────────
    input  wire        id_ex_RegWrite_in,
    input  wire        id_ex_MemToReg_in, // 0=ALUResult, 1=MemData

    // ── Datapath outputs ─────────────────────────────────────────
    output reg  [31:0] id_ex_NPC_out,
    output reg  [31:0] id_ex_A_out,
    output reg  [31:0] id_ex_B_out,
    output reg  [31:0] id_ex_Imm_out,
    output reg  [4:0]  id_ex_RS_out,
    output reg  [4:0]  id_ex_RT_out,
    output reg  [4:0]  id_ex_RD_out,

    // ── EX-stage control outputs ──────────────────────────────────
    output reg         id_ex_RegDst_out,
    output reg         id_ex_ALUSrc_out,
    output reg  [3:0]  id_ex_ALUOp_out,

    // ── MEM-stage control outputs ─────────────────────────────────
    output reg         id_ex_BranchEq_out,
    output reg         id_ex_BranchNe_out,
    output reg         id_ex_MemRead_out,
    output reg         id_ex_MemWrite_out,

    // ── WB-stage control outputs ──────────────────────────────────
    output reg         id_ex_RegWrite_out,
    output reg         id_ex_MemToReg_out
);

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            id_ex_NPC_out      <= 32'b0;
            id_ex_A_out        <= 32'b0;
            id_ex_B_out        <= 32'b0;
            id_ex_Imm_out      <= 32'b0;
            id_ex_RS_out       <= 5'b0;
            id_ex_RT_out       <= 5'b0;
            id_ex_RD_out       <= 5'b0;
            id_ex_RegDst_out   <= 1'b0;
            id_ex_ALUSrc_out   <= 1'b0;
            id_ex_ALUOp_out    <= 4'b0;            
            id_ex_BranchEq_out   <= 1'b0;
            id_ex_BranchNe_out   <= 1'b0;
            id_ex_MemRead_out  <= 1'b0;
            id_ex_MemWrite_out <= 1'b0;
            id_ex_RegWrite_out <= 1'b0;
            id_ex_MemToReg_out <= 1'b0;
        end
        else if (id_ex_stall) begin       // stall: insert bubble, zero control signals
            id_ex_NPC_out      <= 32'b0;
            id_ex_A_out        <= 32'b0;
            id_ex_B_out        <= 32'b0;
            id_ex_Imm_out      <= 32'b0;
            id_ex_RS_out       <= 5'b0;
            id_ex_RT_out       <= 5'b0;
            id_ex_RD_out       <= 5'b0;
            id_ex_RegDst_out   <= 1'b0;
            id_ex_ALUSrc_out   <= 1'b0;
            id_ex_ALUOp_out    <= 4'b0;
            id_ex_BranchEq_out   <= 1'b0;
            id_ex_BranchNe_out   <= 1'b0;
            id_ex_MemRead_out  <= 1'b0;
            id_ex_MemWrite_out <= 1'b0;
            id_ex_RegWrite_out <= 1'b0;
            id_ex_MemToReg_out <= 1'b0;
        end
        else begin                        // normal: latch new values
            id_ex_NPC_out      <= id_ex_NPC_in;
            id_ex_A_out        <= id_ex_A_in;
            id_ex_B_out        <= id_ex_B_in;
            id_ex_Imm_out      <= id_ex_Imm_in;
            id_ex_RS_out       <= id_ex_RS_in;
            id_ex_RT_out       <= id_ex_RT_in;
            id_ex_RD_out       <= id_ex_RD_in;
            id_ex_RegDst_out   <= id_ex_RegDst_in;
            id_ex_ALUSrc_out   <= id_ex_ALUSrc_in;
            id_ex_ALUOp_out    <= id_ex_ALUOp_in;
            id_ex_BranchEq_out   <= id_ex_BranchEq_in;
            id_ex_BranchNe_out   <= id_ex_BranchNe_in;
            id_ex_MemRead_out  <= id_ex_MemRead_in;
            id_ex_MemWrite_out <= id_ex_MemWrite_in;
            id_ex_RegWrite_out <= id_ex_RegWrite_in;
            id_ex_MemToReg_out <= id_ex_MemToReg_in;
        end
    end
endmodule