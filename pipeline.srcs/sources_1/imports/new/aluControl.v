`timescale 1ns / 1ps


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
                    6'b100000: op = 4'b0010;  // ADD
                    6'b100010: op = 4'b0110;  // SUB
                    6'b100100: op = 4'b0000;  // AND
                    6'b100101: op = 4'b0001;  // OR
                    6'b101010: op = 4'b0111;  // SLT
                    6'b100111: op = 4'b1000;  // NOR
                    6'b100110: op = 4'b1001;  // XOR
                    6'b000000:  op = 4'b1010;  // SLL
                    6'b000010:  op = 4'b1011;  // SRL
                    6'b000011:  op = 4'b1100;  // SRA
                    6'b101100:  op = 4'b0100;  // NAND
                    default: op = 4'b0010; // default ADD
                endcase
            end

            4'b0011: op = 4'b0111;  // SLT immediate (custom)

            default: op = 4'b0010;  // fallback: ADD
        endcase
    end
endmodule