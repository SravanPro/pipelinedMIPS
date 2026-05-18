`timescale 1ns / 1ps

/*
  MMIO input map:
    [0]=right [1]=left [2]=up [3]=down [4]=draw [5]=erase [6]=game_reset

  r1 = X (0..127), r2 = Y (0..63)
  Init: X=64, Y=32

  Framebuffer: framebuffer[Y*128+X] = pixel state
    Stored as bit-packed words in DMEM 0x200..0x5FF
    pixel(X,Y) -> flat=Y*128+X -> word@(0x200+(flat>>5)*4), bit=(flat&31)
*/

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

    wire [8191:0] framebuffer = uut.framebuffer;
    wire [31:0]   X           = uut.REGFILE.regBank[1];
    wire [31:0]   Y           = uut.REGFILE.regBank[2];
        
    pipeline #(.inputs(7)) uut (
        .clk         (clk),
        .reset       (reset),
        .memMappedIO (mmio_in),
        .framebuffer (framebuffer)
    );



    // Helper: check if pixel (px,py) is set in framebuffer
    // framebuffer[Y*128+X]
    function pixel_on;
        input [6:0] px;
        input [5:0] py;
        integer flat;
        begin
            flat = py * 128 + px;
            pixel_on = framebuffer[flat];
        end
    endfunction

    always #5 clk = ~clk;

    task loadInstr;
        input [31:0] addr;
        input [31:0] instr;
        begin
            uut.IMEM.mem[addr]   = instr[31:24];
            uut.IMEM.mem[addr+1] = instr[23:16];
            uut.IMEM.mem[addr+2] = instr[15:8];
            uut.IMEM.mem[addr+3] = instr[7:0];
        end
    endtask

    task press;
        input [6:0] mask;
        input integer cycles;
        integer k;
        begin
            {btn_game_reset, btn_erase, btn_draw,
             btn_down, btn_up, btn_left, btn_right} = mask;
            for (k = 0; k < cycles; k = k + 1)
                @(posedge clk);
            {btn_game_reset, btn_erase, btn_draw,
             btn_down, btn_up, btn_left, btn_right} = 7'b0;
        end
    endtask

    // ~130 instrs per loop iteration, ~5 pipeline stages, plus stalls
    localparam CLKS_PER_STEP = 160;

    integer i;

    initial begin
        clk           = 0;
        reset         = 1;
        btn_right     = 0; btn_left  = 0;
        btn_up        = 0; btn_down  = 0;
        btn_draw      = 0; btn_erase = 0;
        btn_game_reset = 0;

        #2;
        for (i = 0; i < 512; i = i + 1) uut.IMEM.mem[i] = 8'h00;
        for (i = 0; i < 6144; i = i + 1) uut.DMEM.mem[i] = 8'h00;

        // ==================================================
        // PAINTER PROGRAM  (492 bytes, fits in 512-byte IMEM)
        //
        // Register map:
        //   r1=X  r2=Y  r3=flat  r4=word_idx  r5=bit_idx
        //   r6=FB_word_addr  r7=word  r8=mask  r9=result
        //   r10=MMIO_BASE  r11=scratch
        //   r12=right r13=left r14=up r15=down r16=draw r17=erase r18=game_reset
        //   r19=FB_BASE(0x200)
        //
        // Framebuffer layout in DMEM:
        //   pixel(X,Y): flat=Y*128+X
        //   word addr = 0x200 + (flat>>5)*4
        //   bit  = flat & 31  (bit0=LSB of that word)
        // ==================================================

        // --- INIT (addr 0) ---
        loadInstr(   0, 32'h3C0AFFFF); // lui  r10, 0xFFFF
        loadInstr(   4, 32'h354AFF00); // ori  r10, r10, 0xFF00  -> MMIO base
        loadInstr(   8, 32'h20010040); // addi r1,  r0,  64      X=64
        loadInstr(  12, 32'h20020020); // addi r2,  r0,  32      Y=32
        loadInstr(  16, 32'h20130200); // addi r19, r0,  0x200   FB_BASE

        // --- LOOP (addr 20): latch all buttons ---
        loadInstr(  20, 32'h8D4C0000); // lw r12,0(r10) right
        loadInstr(  24, 32'h8D4D0001); // lw r13,1(r10) left
        loadInstr(  28, 32'h8D4E0002); // lw r14,2(r10) up
        loadInstr(  32, 32'h8D4F0003); // lw r15,3(r10) down
        loadInstr(  36, 32'h8D500004); // lw r16,4(r10) draw
        loadInstr(  40, 32'h8D510005); // lw r17,5(r10) erase
        loadInstr(  44, 32'h8D520006); // lw r18,6(r10) game_reset
        loadInstr(  48, 32'h00000000); // nop
        loadInstr(  52, 32'h00000000); // nop
        loadInstr(  56, 32'h00000000); // nop

        // game_reset
        loadInstr(  60, 32'h12400004); // beq r18,r0,skip_greset  off=4 ->80
        loadInstr(  64, 32'h00000000); // nop
        loadInstr(  68, 32'h00000000); // nop
        loadInstr(  72, 32'h00000000); // nop
        loadInstr(  76, 32'h08000000); // j INIT ->0
        // skip_greset=80

        // RIGHT
        loadInstr(  80, 32'h1180000C); // beq r12,r0,skip_right off=12 ->132
        loadInstr(  84, 32'h00000000); // nop
        loadInstr(  88, 32'h00000000); // nop
        loadInstr(  92, 32'h00000000); // nop
        loadInstr(  96, 32'h282B007F); // slti r11,r1,127
        loadInstr( 100, 32'h00000000); // nop
        loadInstr( 104, 32'h00000000); // nop
        loadInstr( 108, 32'h00000000); // nop
        loadInstr( 112, 32'h11600004); // beq r11,r0,skip_right off=4 ->132
        loadInstr( 116, 32'h00000000); // nop
        loadInstr( 120, 32'h00000000); // nop
        loadInstr( 124, 32'h00000000); // nop
        loadInstr( 128, 32'h20210001); // addi r1,r1,1
        // skip_right=132

        // LEFT
        loadInstr( 132, 32'h11A00008); // beq r13,r0,skip_left off=8 ->168
        loadInstr( 136, 32'h00000000); // nop
        loadInstr( 140, 32'h00000000); // nop
        loadInstr( 144, 32'h00000000); // nop
        loadInstr( 148, 32'h10200004); // beq r1,r0,skip_left off=4 ->168
        loadInstr( 152, 32'h00000000); // nop
        loadInstr( 156, 32'h00000000); // nop
        loadInstr( 160, 32'h00000000); // nop
        loadInstr( 164, 32'h2021FFFF); // addi r1,r1,-1
        // skip_left=168

        // UP
        loadInstr( 168, 32'h11C0000C); // beq r14,r0,skip_up off=12 ->220
        loadInstr( 172, 32'h00000000); // nop
        loadInstr( 176, 32'h00000000); // nop
        loadInstr( 180, 32'h00000000); // nop
        loadInstr( 184, 32'h284B003F); // slti r11,r2,63
        loadInstr( 188, 32'h00000000); // nop
        loadInstr( 192, 32'h00000000); // nop
        loadInstr( 196, 32'h00000000); // nop
        loadInstr( 200, 32'h11600004); // beq r11,r0,skip_up off=4 ->220
        loadInstr( 204, 32'h00000000); // nop
        loadInstr( 208, 32'h00000000); // nop
        loadInstr( 212, 32'h00000000); // nop
        loadInstr( 216, 32'h20420001); // addi r2,r2,1
        // skip_up=220

        // DOWN
        loadInstr( 220, 32'h11E00008); // beq r15,r0,skip_down off=8 ->252  (was 256 bug fixed below)
        loadInstr( 224, 32'h00000000); // nop
        loadInstr( 228, 32'h00000000); // nop
        loadInstr( 232, 32'h00000000); // nop
        loadInstr( 236, 32'h10400004); // beq r2,r0,skip_down off=4 ->256
        loadInstr( 240, 32'h00000000); // nop
        loadInstr( 244, 32'h00000000); // nop
        loadInstr( 248, 32'h00000000); // nop
        loadInstr( 252, 32'h2042FFFF); // addi r2,r2,-1
        // skip_down=256

        // Compute framebuffer address
        loadInstr( 256, 32'h000219C0); // sll  r3,r2,7          r3 = Y<<7
        loadInstr( 260, 32'h00000000); // nop
        loadInstr( 264, 32'h00000000); // nop
        loadInstr( 268, 32'h00000000); // nop
        loadInstr( 272, 32'h00611820); // add  r3,r3,r1         r3 = flat
        loadInstr( 276, 32'h00000000); // nop
        loadInstr( 280, 32'h00000000); // nop
        loadInstr( 284, 32'h00000000); // nop
        loadInstr( 288, 32'h00032142); // srl  r4,r3,5          r4 = word_idx
        loadInstr( 292, 32'h00000000); // nop
        loadInstr( 296, 32'h00000000); // nop
        loadInstr( 300, 32'h00000000); // nop
        loadInstr( 304, 32'h3065001F); // andi r5,r3,31         r5 = bit_idx
        loadInstr( 308, 32'h00000000); // nop
        loadInstr( 312, 32'h00000000); // nop
        loadInstr( 316, 32'h00000000); // nop
        loadInstr( 320, 32'h00043080); // sll  r6,r4,2          r6 = word_idx*4
        loadInstr( 324, 32'h00000000); // nop
        loadInstr( 328, 32'h00000000); // nop
        loadInstr( 332, 32'h00000000); // nop
        loadInstr( 336, 32'h00D33020); // add  r6,r6,r19        r6 = FB word addr
        loadInstr( 340, 32'h00000000); // nop
        loadInstr( 344, 32'h00000000); // nop
        loadInstr( 348, 32'h00000000); // nop
        loadInstr( 352, 32'h8CC70000); // lw   r7,0(r6)         r7 = current word
        loadInstr( 356, 32'h00000000); // nop
        loadInstr( 360, 32'h00000000); // nop
        loadInstr( 364, 32'h00000000); // nop
        loadInstr( 368, 32'h20080001); // addi r8,r0,1          r8 = 1
        loadInstr( 372, 32'h00000000); // nop
        loadInstr( 376, 32'h00000000); // nop
        loadInstr( 380, 32'h00000000); // nop
        loadInstr( 384, 32'h00A84004); // sllv r8,r8,r5         r8 = 1<<bit_idx
        loadInstr( 388, 32'h00000000); // nop
        loadInstr( 392, 32'h00000000); // nop
        loadInstr( 396, 32'h00000000); // nop

        // DRAW
        loadInstr( 400, 32'h12000008); // beq r16,r0,skip_draw off=8 ->436
        loadInstr( 404, 32'h00000000); // nop
        loadInstr( 408, 32'h00000000); // nop
        loadInstr( 412, 32'h00000000); // nop
        loadInstr( 416, 32'h00E84825); // or   r9,r7,r8
        loadInstr( 420, 32'h00000000); // nop
        loadInstr( 424, 32'h00000000); // nop
        loadInstr( 428, 32'h00000000); // nop
        loadInstr( 432, 32'hACC90000); // sw   r9,0(r6)
        // skip_draw=436

        // ERASE
        loadInstr( 436, 32'h1220000C); // beq r17,r0,skip_erase off=12 ->488
        loadInstr( 440, 32'h00000000); // nop
        loadInstr( 444, 32'h00000000); // nop
        loadInstr( 448, 32'h00000000); // nop
        loadInstr( 452, 32'h01004027); // nor  r8,r8,r0         r8 = ~r8
        loadInstr( 456, 32'h00000000); // nop
        loadInstr( 460, 32'h00000000); // nop
        loadInstr( 464, 32'h00000000); // nop
        loadInstr( 468, 32'h00E84824); // and  r9,r7,r8
        loadInstr( 472, 32'h00000000); // nop
        loadInstr( 476, 32'h00000000); // nop
        loadInstr( 480, 32'h00000000); // nop
        loadInstr( 484, 32'hACC90000); // sw   r9,0(r6)
        // skip_erase=488

        loadInstr( 488, 32'h08000005); // j LOOP ->20

        // --------------------------------------------------
        // Deassert hardware reset
        // --------------------------------------------------
        #15;
        reset = 0;
        repeat(300) @(posedge clk); // pipeline warmup + INIT execution

        // ==================================================
        // TEST 1: move right to X=127, hold (boundary test)
        // ==================================================
        press(7'b0000001, (63+30)*CLKS_PER_STEP);
        // X should be 127
        repeat(20) @(posedge clk);

        // ==================================================
        // TEST 2: move left to X=0, hold (boundary test)
        // ==================================================
        press(7'b0000010, (127+30)*CLKS_PER_STEP);
        // X should be 0
        repeat(20) @(posedge clk);

        // ==================================================
        // TEST 3: back to centre X=64
        // ==================================================
        press(7'b0000001, 64*CLKS_PER_STEP);
        repeat(20) @(posedge clk);

        // ==================================================
        // TEST 4: game_reset -> X=64, Y=32
        // ==================================================
        press(7'b1000000, 10*CLKS_PER_STEP);
        repeat(20) @(posedge clk);

        // ==================================================
        // TEST 5: draw a horizontal line moving right
        // ==================================================
        press(7'b0010001, 20*CLKS_PER_STEP); // right + draw
        repeat(20) @(posedge clk);

        // ==================================================
        // TEST 6: erase while moving left (erase the line)
        // ==================================================
        press(7'b0100010, 20*CLKS_PER_STEP); // left + erase
        repeat(20) @(posedge clk);

        // ==================================================
        // TEST 7: game_reset -> X=64, Y=32
        // ==================================================
        press(7'b1000000, 10*CLKS_PER_STEP);
        repeat(20) @(posedge clk);

        // ==================================================
        // TEST 8: move up to Y=63 (boundary test)
        // ==================================================
        press(7'b0000100, (31+30)*CLKS_PER_STEP);
        // Y should be 63
        repeat(20) @(posedge clk);

        // ==================================================
        // TEST 9: move down to Y=0 (boundary test)
        // ==================================================
        press(7'b0001000, (63+30)*CLKS_PER_STEP);
        // Y should be 0
        repeat(20) @(posedge clk);

        // ==================================================
        // TEST 10: game_reset -> X=64, Y=32
        // ==================================================
        press(7'b1000000, 10*CLKS_PER_STEP);
        repeat(200) @(posedge clk);

        $finish;
    end

endmodule