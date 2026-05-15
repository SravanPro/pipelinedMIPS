`timescale 1ns / 1ps

// ALU with 4-bit operation select (16 possible operations)
module alu(
    input  [31:0] a,
    input  [31:0] b,
    input  [3:0]  op,
    output reg [31:0] result,
    output reg        zero
);

    always @(*) begin
        case(op)
            // ── Original operations (encoding preserved, just zero-extended) ──
            4'b0010: result = a + b;                          // ADD
            4'b0110: result = a - b;                          // SUB
            4'b0000: result = a & b;                          // AND
            4'b0001: result = a | b;                          // OR
            4'b0111: result = ($signed(a) < $signed(b)) ? 32'd1 : 32'd0; // SLT

            // ── New operations ────────────────────────────────────────────────
            4'b0100: result = ~(a & b);                       // NAND
            4'b1000: result = ~(a | b);                       // NOR
            4'b1001: result = a ^ b;                          // XOR
            4'b1010: result = b << a[4:0];                    // SLL (shift amt in a)
            4'b1011: result = b >> a[4:0];                    // SRL
            4'b1100: result = $signed(b) >>> a[4:0];          // SRA (arithmetic)
            4'b1101: result = a + 32'd1;                      // INC
            4'b1110: result = a - 32'd1;                      // DEC
            4'b1111: result = (a == b) ? 32'd1 : 32'd0;       // EQ (useful for beq)

            default: result = 32'd0;
        endcase

        zero = (result == 32'd0) ? 1'b1 : 1'b0;
    end
endmodule