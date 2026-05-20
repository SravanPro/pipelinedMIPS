`timescale 1ns / 1ps

module movementDivider(
    input        clock,
    input        reset,
    input        rightRaw, leftRaw, upRaw, downRaw,
    input        speedInc, speedDec,
    output reg   right, left, up, down,
    output [3:0] speedOut
);

    // debounce: 20ms at 50MHz = 1,000,000 cycles
    parameter DEBOUNCE_COUNT = 1_000_000;
    
    // Pulse stretch window: how many clock cycles the output stays high 
    // per divider period so the CPU polling loop can catch it.
    parameter PULSE_WIDTH = 100;

    // debounce for speedInc
    reg [19:0] db_inc_cnt;
    reg        db_inc_state;
    reg        db_inc_prev;
    always @(posedge clock or posedge reset) begin
        if (reset) begin
            db_inc_cnt   <= 0;
            db_inc_state <= 0;
            db_inc_prev  <= 0;
        end else begin
            db_inc_prev <= db_inc_state;
            if (speedInc == db_inc_state) begin
                db_inc_cnt <= 0;
            end else begin
                if (db_inc_cnt >= DEBOUNCE_COUNT - 1) begin
                    db_inc_state <= speedInc;
                    db_inc_cnt   <= 0;
                end else begin
                    db_inc_cnt <= db_inc_cnt + 1;
                end
            end
        end
    end
    wire speedInc_rising = db_inc_state & ~db_inc_prev;

    // debounce for speedDec
    reg [19:0] db_dec_cnt;
    reg        db_dec_state;
    reg        db_dec_prev;
    always @(posedge clock or posedge reset) begin
        if (reset) begin
            db_dec_cnt   <= 0;
            db_dec_state <= 0;
            db_dec_prev  <= 0;
        end else begin
            db_dec_prev <= db_dec_state;
            if (speedDec == db_dec_state) begin
                db_dec_cnt <= 0;
            end else begin
                if (db_dec_cnt >= DEBOUNCE_COUNT - 1) begin
                    db_dec_state <= speedDec;
                    db_dec_cnt   <= 0;
                end else begin
                    db_dec_cnt <= db_dec_cnt + 1;
                end
            end
        end
    end
    wire speedDec_rising = db_dec_state & ~db_dec_prev;

    // speed: 1-15, default 4
    reg [3:0] speed;
    assign speedOut = speed;

    reg [19:0] divider;
    always @(*) begin
        case (speed)
            4'd1:  divider = 20'd666666;
            4'd2:  divider = 20'd333333;
            4'd3:  divider = 20'd222222;
            4'd4:  divider = 20'd166666;
            4'd5:  divider = 20'd133333;
            4'd6:  divider = 20'd111111;
            4'd7:  divider = 20'd95238;
            4'd8:  divider = 20'd83333;
            4'd9:  divider = 20'd74074;
            4'd10: divider = 20'd66666;
            4'd11: divider = 20'd60606;
            4'd12: divider = 20'd55555;
            4'd13: divider = 20'd51282;
            4'd14: divider = 20'd47619;
            4'd15: divider = 20'd44444;
            default: divider = 20'd166666;
        endcase
    end

    reg [19:0] counter;

    always @(posedge clock or posedge reset) begin
        if (reset) begin
            speed   <= 4'd4;
            counter <= 0;
            right   <= 0; left <= 0; up <= 0; down <= 0;
        end else begin
            if (speedInc_rising && speed < 4'd15)
                speed <= speed + 1;
            else if (speedDec_rising && speed > 4'd1)
                speed <= speed - 1;

            if (counter >= divider - 1) begin
                counter <= 0;
            end else begin
                counter <= counter + 1;
            end

            // Pulse Stretching Logic
            // Hold the outputs to their raw states for the first PULSE_WIDTH cycles 
            // of the divider period. This ensures the CPU scan loop catches it.
            if (counter < PULSE_WIDTH) begin
                right <= rightRaw;
                left  <= leftRaw;
                up    <= upRaw;
                down  <= downRaw;
            end else begin
                right <= 0; 
                left  <= 0; 
                up    <= 0; 
                down  <= 0;
            end
        end
    end

endmodule