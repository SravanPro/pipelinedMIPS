`timescale 1ns / 1ps

module if_id (
    input  wire        clk,
    input  wire        reset,
    input  wire        if_id_stall,   // 1 = freeze (stall), 0 = normal latch
    input  wire        if_id_flush,   // 1 = zero out IR (branch misprediction flush)
    input  wire [31:0] if_id_NPC_in,
    input  wire [31:0] if_id_IR_in,

    output reg  [31:0] if_id_NPC_out,
    output reg  [31:0] if_id_IR_out
);
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            if_id_NPC_out <= 32'b0;
            if_id_IR_out  <= 32'b0;
        end
        else if (if_id_flush) begin       // branch misprediction: kill instruction
            if_id_NPC_out <= 32'b0;
            if_id_IR_out  <= 32'b0;       // NOP (sll $0,$0,0)
        end
        else if (if_id_stall) begin       // stall: hold current values
            if_id_NPC_out <= if_id_NPC_out;
            if_id_IR_out  <= if_id_IR_out;
        end
        else begin                        // normal: latch new values
            if_id_NPC_out <= if_id_NPC_in;
            if_id_IR_out  <= if_id_IR_in;
        end
    end
endmodule