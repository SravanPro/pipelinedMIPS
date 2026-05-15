`timescale 1ns / 1ps

module pc(
    input        clock,
    input        reset,
    input        pcStall,         // 1 = freeze PC (stall), 0 = normal update
    input [31:0] pcInVal,
    output reg [31:0] pcOutVal
);

    always @(posedge clock or posedge reset) begin
        if (reset) begin
            pcOutVal <= 32'd0;
        end
        else if (pcStall) begin   // stall: hold current PC
            pcOutVal <= pcOutVal;
        end
        else begin                // normal: update PC
            pcOutVal <= pcInVal;
        end
    end

endmodule