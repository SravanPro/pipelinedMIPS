`timescale 1ns / 1ps



module crosshair (
    input  [31:0] X,          // cursor X from r1  (0..127)
    input  [31:0] Y,          // cursor Y from r2  (0..63)
    output reg [8191:0] crosshairFB
);

    integer px, py;
    integer dx, dy;
    integer flat;

    always @(*) begin

        crosshairFB = 8192'b0;

        for (py = 0; py < 64; py = py + 1) begin
            for (px = 0; px < 128; px = px + 1) begin

                // unsigned distance from cursor
                dx = (px >= X) ? (px - X) : (X - px);
                dy = (py >= Y) ? (py - Y) : (Y - py);

                if (
                    // centre pixel
                    (dx == 0 && dy == 0) ||
                    // outer ring: Chebyshev distance == 2
                    // (all pixels where max(dx,dy)==2, i.e. dx<=2 && dy<=2 && max==2)
                    (dx <= 2 && dy <= 2 && (dx == 2 || dy == 2))
                ) begin
                    flat = py * 128 + px;
                    crosshairFB[flat] = 1'b1;
                end

            end
        end
    end

endmodule