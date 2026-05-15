`timescale 1ns / 1ps

// MEM/WB Pipeline Register
// MEM control signals (Branch, MemRead, MemWrite) consumed in MEM - NOT passed.
// Only WB control signals + datapath results pass through.

module mem_wb (
    input  wire        clk,
    input  wire        reset,

    // ── Datapath inputs ───────────────────────────────────────────
    input  wire [31:0] mem_wb_LMD_in,        // Load Memory Data
    input  wire [31:0] mem_wb_AluOut_in,      // ALU result (pass-through for non-load)
    input  wire [4:0]  mem_wb_RegDest_in,     // destination register

    // ── WB-stage control inputs ───────────────────────────────────
    input  wire        mem_wb_RegWrite_in,
    input  wire        mem_wb_MemToReg_in,    // 0=ALUOut, 1=LMD

    // ── Datapath outputs ──────────────────────────────────────────
    output reg  [31:0] mem_wb_LMD_out,
    output reg  [31:0] mem_wb_AluOut_out,
    output reg  [4:0]  mem_wb_RegDest_out,

    // ── WB-stage control outputs ──────────────────────────────────
    output reg         mem_wb_RegWrite_out,
    output reg         mem_wb_MemToReg_out
);

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            mem_wb_LMD_out      <= 32'b0;
            mem_wb_AluOut_out   <= 32'b0;
            mem_wb_RegDest_out  <= 5'b0;
            mem_wb_RegWrite_out <= 1'b0;
            mem_wb_MemToReg_out <= 1'b0;
        end
        else begin
            mem_wb_LMD_out      <= mem_wb_LMD_in;
            mem_wb_AluOut_out   <= mem_wb_AluOut_in;
            mem_wb_RegDest_out  <= mem_wb_RegDest_in;
            mem_wb_RegWrite_out <= mem_wb_RegWrite_in;
            mem_wb_MemToReg_out <= mem_wb_MemToReg_in;
        end
    end
endmodule