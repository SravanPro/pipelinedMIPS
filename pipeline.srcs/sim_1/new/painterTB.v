`timescale 1ns / 1ps

module painterTB ();

    reg clk, reset;
    reg btn_right, btn_left, btn_up, btn_down;
    reg btn_draw, btn_erase, btn_game_reset;

    wire [6:0] mmio_in;

    assign mmio_in[0] = btn_right;
    assign mmio_in[1] = btn_left;
    assign mmio_in[2] = btn_up;
    assign mmio_in[3] = btn_down;
    assign mmio_in[4] = btn_draw;
    assign mmio_in[5] = btn_erase;
    assign mmio_in[6] = btn_game_reset;

    wire [8191:0] framebuffer;
    wire memWrite = uut.DMEM.memWrite;

    wire [31:0] r1_X = uut.REGFILE.regBank[1];
    wire [31:0] r2_Y = uut.REGFILE.regBank[2];

    pipeline #(.inputs(7)) uut (
        .clk         (clk),
        .reset       (reset),
        .memMappedIO (mmio_in),
        .framebuffer (framebuffer)
    );

    always #5 clk = ~clk;

    // =========================================================
    // FRAMEBUFFER DUMP LOGIC
    // =========================================================

    integer frame_file;
    integer x, y, flat;
    reg     prev_memWrite;

    initial begin
        prev_memWrite = 0;

        // clear old file
        frame_file = $fopen("frames.txt", "w");
        $fclose(frame_file);
    end

    task dump_framebuffer;
        begin
            frame_file = $fopen("frames.txt", "a");

            for (y = 0; y < 64; y = y + 1) begin

                for (x = 0; x < 128; x = x + 1) begin

                    flat = y * 128 + x;

                    $fwrite(
                        frame_file,
                        "%0d",
                        framebuffer[flat]
                    );
                end

                $fwrite(frame_file, "\n");
            end

            $fwrite(
                frame_file,
                "========================================\n"
            );

            $fclose(frame_file);
        end
    endtask

    always @(posedge clk) begin

        // dump only on rising edge of memWrite
        if (memWrite && !prev_memWrite)
            dump_framebuffer();

        prev_memWrite <= memWrite;
    end

    // =========================================================
    // PIXEL HELPER
    // =========================================================

    function pixel_on;
        input [6:0] px;
        input [5:0] py;

        integer f;

        begin
            f = py * 128 + px;
            pixel_on = framebuffer[f];
        end
    endfunction

    // =========================================================
    // BUTTON PRESS TASK
    // =========================================================

    localparam CLKS_PER_STEP = 160;

    integer k;

    task press;
        input [6:0] mask;
        input integer cycles;

        begin

            {
                btn_game_reset,
                btn_erase,
                btn_draw,
                btn_down,
                btn_up,
                btn_left,
                btn_right
            } = mask;

            for (k = 0; k < cycles; k = k + 1)
                @(posedge clk);

            {
                btn_game_reset,
                btn_erase,
                btn_draw,
                btn_down,
                btn_up,
                btn_left,
                btn_right
            } = 7'b0;

        end
    endtask

    // =========================================================
    // MAIN TEST SEQUENCE
    // =========================================================

    initial begin

        clk            = 0;
        reset          = 1;

        btn_right      = 0;
        btn_left       = 0;
        btn_up         = 0;
        btn_down       = 0;
        btn_draw       = 0;
        btn_erase      = 0;
        btn_game_reset = 0;

        #20;
        reset = 0;

        repeat(300)
            @(posedge clk);

        // TEST 1: move right to X=127 (boundary)
        press(7'b0000001, (63 + 30) * CLKS_PER_STEP);
        repeat(20) @(posedge clk);

        // TEST 2: move left to X=0 (boundary)
        press(7'b0000010, (127 + 30) * CLKS_PER_STEP);
        repeat(20) @(posedge clk);

        // TEST 3: back to centre X=64
        press(7'b0000001, 64 * CLKS_PER_STEP);
        repeat(20) @(posedge clk);

        // TEST 4: game_reset -> X=64, Y=32
        press(7'b1000000, 10 * CLKS_PER_STEP);
        repeat(20) @(posedge clk);

        // TEST 5: draw horizontal line moving right
        press(7'b0010001, 20 * CLKS_PER_STEP);
        repeat(20) @(posedge clk);

        // TEST 6: erase while moving left
        press(7'b0100010, 20 * CLKS_PER_STEP);
        repeat(20) @(posedge clk);

        // TEST 7: game_reset -> X=64, Y=32
        press(7'b1000000, 10 * CLKS_PER_STEP);
        repeat(20) @(posedge clk);

        // TEST 8: move up to Y=63 (boundary)
        press(7'b0000100, (31 + 30) * CLKS_PER_STEP);
        repeat(20) @(posedge clk);

        // TEST 9: move down to Y=0 (boundary)
        press(7'b0001000, (63 + 30) * CLKS_PER_STEP);
        repeat(20) @(posedge clk);

        // TEST 10: game_reset -> X=64, Y=32
        press(7'b1000000, 10 * CLKS_PER_STEP);
        repeat(200) @(posedge clk);

        // ==================================================
        // TEST 11: Draw X shape
        // ==================================================

        // TEST 11: Draw X shape
        // ==================================================

        // Hard reset to clear framebuffer before drawing X
        reset = 1;
        repeat(10) @(posedge clk);
        reset = 0;
        repeat(300) @(posedge clk); // warmup
        
        // Navigate to (0,0)
        press(7'b0000010, 64 * CLKS_PER_STEP);
        repeat(20) @(posedge clk);

        press(7'b0001000, 32 * CLKS_PER_STEP);
        repeat(20) @(posedge clk);

        // Draw diagonal bottom-left -> top-right
        press(7'b0010101, 63 * CLKS_PER_STEP);
        repeat(20) @(posedge clk);

        // Move down
        press(7'b0001000, 63 * CLKS_PER_STEP);
        repeat(20) @(posedge clk);

        // Draw diagonal bottom-right -> top-left
        press(7'b0010110, 63 * CLKS_PER_STEP);
        repeat(20) @(posedge clk);

        repeat(200)
            @(posedge clk);

        $finish;
    end

endmodule