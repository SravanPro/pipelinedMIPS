`timescale 1ns / 1ps

// ALU Control - takes 4-bit aluOp from control + 6-bit funct field
// Produces 4-bit ALU operation for the ALU
//
// aluOp encoding (from mainControl):
//   4'b0000 : add  (lw / sw address calc)
//   4'b0001 : sub  (beq comparison)
//   4'b0010 : R-type (decode using funct field)
//   4'b0011 : reserved / custom
//
// funct field encoding (R-type):
//   6'b100000 (32): ADD
//   6'b100010 (34): SUB
//   6'b100100 (36): AND
//   6'b100101 (37): OR
//   6'b101010 (42): SLT
//   6'b100111 (39): NOR
//   6'b100110 (38): XOR
//   6'b000000 (0) : SLL
//   6'b000010 (2) : SRL
//   6'b000011 (3) : SRA

module aluControl(
    input  [3:0] aluOp,
    input  [5:0] func,
    output reg [3:0] op
);

    always @(*) begin
        case (aluOp)
            4'b0000: op = 4'b0010;  // ADD  (lw/sw)
            4'b0001: op = 4'b0110;  // SUB  (beq)

            4'b0010: begin           // R-type: decode funct
                case (func)
                    6'd32: op = 4'b0010;  // ADD
                    6'd34: op = 4'b0110;  // SUB
                    6'd36: op = 4'b0000;  // AND
                    6'd37: op = 4'b0001;  // OR
                    6'd42: op = 4'b0111;  // SLT
                    6'd39: op = 4'b1000;  // NOR
                    6'd38: op = 4'b1001;  // XOR
                    6'd0:  op = 4'b1010;  // SLL
                    6'd2:  op = 4'b1011;  // SRL
                    6'd3:  op = 4'b1100;  // SRA
                    default: op = 4'b0010; // default ADD
                endcase
            end

            4'b0011: op = 4'b0111;  // SLT immediate (custom)

            default: op = 4'b0010;  // fallback: ADD
        endcase
    end
endmodule