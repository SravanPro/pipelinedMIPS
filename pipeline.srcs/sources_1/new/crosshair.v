`timescale 1ns / 1ps

// Sequential crosshair framebuffer
// Latency: 18 cycles max (1 clear + 17 pixel writes) = 360 ns @ 50 MHz
// No combinational multipliers or dividers.
// py*128 == {py, 7'b0} — pure wiring, zero LUTs.

module crosshair (
    input             clock,
    input             reset,
    input      [31:0] X,
    input      [31:0] Y,
    output reg [8191:0] crosshairFB
);

    localparam STEPS = 5'd17;

    reg [4:0] step;
    reg       active;
    reg [6:0] Xr;
    reg [5:0] Yr;

    // ------------------------------------------------------------------
    // Offset decode — combinational, pure mux, no mult/div
    // ------------------------------------------------------------------
    reg signed [3:0] ox, oy;

    always @(*) begin
        case (step)
            5'd1:  begin ox = -4'sd2; oy = -4'sd2; end
            5'd2:  begin ox = -4'sd1; oy = -4'sd2; end
            5'd3:  begin ox =  4'sd0; oy = -4'sd2; end
            5'd4:  begin ox =  4'sd1; oy = -4'sd2; end
            5'd5:  begin ox =  4'sd2; oy = -4'sd2; end
            5'd6:  begin ox = -4'sd2; oy = -4'sd1; end
            5'd7:  begin ox =  4'sd2; oy = -4'sd1; end
            5'd8:  begin ox = -4'sd2; oy =  4'sd0; end
            5'd9:  begin ox =  4'sd0; oy =  4'sd0; end
            5'd10: begin ox =  4'sd2; oy =  4'sd0; end
            5'd11: begin ox = -4'sd2; oy =  4'sd1; end
            5'd12: begin ox =  4'sd2; oy =  4'sd1; end
            5'd13: begin ox = -4'sd2; oy =  4'sd2; end
            5'd14: begin ox = -4'sd1; oy =  4'sd2; end
            5'd15: begin ox =  4'sd0; oy =  4'sd2; end
            5'd16: begin ox =  4'sd1; oy =  4'sd2; end
            5'd17: begin ox =  4'sd2; oy =  4'sd2; end
            default: begin ox = 4'sd0; oy = 4'sd0; end
        endcase
    end

    // ------------------------------------------------------------------
    // Pixel address — combinational wires, computed from current step's
    // offset. No blocking assignments in clocked logic.
    // ------------------------------------------------------------------
    wire signed [8:0] px_s = $signed({2'b00, Xr}) + $signed(ox);
    wire signed [7:0] py_s = $signed({2'b00, Yr}) + $signed(oy);
    wire              in_bounds = (px_s >= 0) && (px_s <= 127) &&
                                  (py_s >= 0) && (py_s <= 63);
    wire [13:0]       flat = {py_s[5:0], 7'b0} | {7'b0, px_s[6:0]};

    // ------------------------------------------------------------------
    // Single FSM block — one driver for every register
    // ------------------------------------------------------------------
    always @(posedge clock) begin
        if (reset) begin
            Xr          <= 7'd0;
            Yr          <= 6'd0;
            step        <= 5'd0;
            active      <= 1'b1;
            crosshairFB <= 8192'b0;
        end else begin

            // Input-change detection: restart whenever X or Y changes
            if (X[6:0] != Xr || Y[5:0] != Yr) begin
                Xr     <= X[6:0];
                Yr     <= Y[5:0];
                step   <= 5'd0;
                active <= 1'b1;
            end

            // FSM advance (only when active)
            if (active) begin
                if (step == 5'd0) begin
                    crosshairFB <= 8192'b0;   // clear
                    step        <= step + 5'd1;
                end else if (step <= STEPS) begin
                    if (in_bounds)
                        crosshairFB[flat] <= 1'b1;
                    if (step == STEPS) begin
                        step   <= 5'd0;
                        active <= 1'b0;
                    end else begin
                        step <= step + 5'd1;
                    end
                end
            end

        end
    end

endmodule