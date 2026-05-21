`timescale 1ns / 1ps

module pipelineTB_copyingArray();

    reg clock;
    reg reset;

    pipeline uut (
        .clock   (clock),
        .reset (reset)
    );

    // Probe wires for quick waveform viewing (no manual drag/drop needed)
    // Source words: 0x00, 0x04, 0x08, 0x0C
    wire [31:0] src_w0 = {uut.DMEM.mem[8'h00], uut.DMEM.mem[8'h01], uut.DMEM.mem[8'h02], uut.DMEM.mem[8'h03]};
    wire [31:0] src_w1 = {uut.DMEM.mem[8'h04], uut.DMEM.mem[8'h05], uut.DMEM.mem[8'h06], uut.DMEM.mem[8'h07]};
    wire [31:0] src_w2 = {uut.DMEM.mem[8'h08], uut.DMEM.mem[8'h09], uut.DMEM.mem[8'h0A], uut.DMEM.mem[8'h0B]};
    wire [31:0] src_w3 = {uut.DMEM.mem[8'h0C], uut.DMEM.mem[8'h0D], uut.DMEM.mem[8'h0E], uut.DMEM.mem[8'h0F]};

    // Destination words: 0x20, 0x24, 0x28, 0x2C
    wire [31:0] dst_w0 = {uut.DMEM.mem[8'h20], uut.DMEM.mem[8'h21], uut.DMEM.mem[8'h22], uut.DMEM.mem[8'h23]};
    wire [31:0] dst_w1 = {uut.DMEM.mem[8'h24], uut.DMEM.mem[8'h25], uut.DMEM.mem[8'h26], uut.DMEM.mem[8'h27]};
    wire [31:0] dst_w2 = {uut.DMEM.mem[8'h28], uut.DMEM.mem[8'h29], uut.DMEM.mem[8'h2A], uut.DMEM.mem[8'h2B]};
    wire [31:0] dst_w3 = {uut.DMEM.mem[8'h2C], uut.DMEM.mem[8'h2D], uut.DMEM.mem[8'h2E], uut.DMEM.mem[8'h2F]};

    // Loop registers used by the copy program
    wire [31:0] r1_count = uut.REGFILE.regBank[1];
    wire [31:0] r5_data  = uut.REGFILE.regBank[5];
    wire [31:0] r21_src  = uut.REGFILE.regBank[21];
    wire [31:0] r22_dst  = uut.REGFILE.regBank[22];

    always #5 clock = ~clock;

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

    integer i;

    initial begin
        clock   = 0;
        reset = 1;
        #17;
        reset = 0;
        #1;

        // ------------------------------------------------
        // Clear memories
        // ------------------------------------------------
        for (i = 0; i < 256; i = i + 1) uut.IMEM.mem[i] = 8'h00;
        for (i = 0; i < 256; i = i + 1) uut.DMEM.mem[i] = 8'h00;

        // ------------------------------------------------
        // Source data: DEADBEEFDEADBEEF into addresses 0x00..0x1C
        // 8 bytes = 2 words:
        //   mem[0x00..0x03] = 0xDEADBEEF
        //   mem[0x04..0x07] = 0xDEADBEEF
        //   mem[0x08..0x0B] = 0xDEADBEEF
        //   mem[0x0C..0x0F] = 0xDEADBEEF
        //   mem[0x10..0x13] = 0xDEADBEEF
        //   mem[0x14..0x17] = 0xDEADBEEF
        //   mem[0x18..0x1B] = 0xDEADBEEF
        //   mem[0x1C..0x1F] = 0xDEADBEEF
        // ------------------------------------------------
        for (i = 0; i < 16; i = i + 4) begin
            uut.DMEM.mem[i]   = 8'hDE;
            uut.DMEM.mem[i+1] = 8'hAD;
            uut.DMEM.mem[i+2] = 8'hBE;
            uut.DMEM.mem[i+3] = 8'hEF;
        end

        // ------------------------------------------------
        // Instructions (3 NOPs between each)
        // ------------------------------------------------

        // [0x00] addi $21, $0, 0x00   -> $21 = 0 (source base)
        loadInstr(0,   32'h20150000);
        loadInstr(4,   32'h00000000); // NOP
        loadInstr(8,   32'h00000000); // NOP
        loadInstr(12,  32'h00000000); // NOP

        // [0x10] addi $22, $0, 0x20   -> $22 = 0x20 (dest base)
        loadInstr(16,  32'h20160020);
        loadInstr(20,  32'h00000000); // NOP
        loadInstr(24,  32'h00000000); // NOP
        loadInstr(28,  32'h00000000); // NOP

        // [0x20] addi $1, $0, 4       -> $1 = 4 (loop counter)
        loadInstr(32,  32'h20010004);
        loadInstr(36,  32'h00000000); // NOP
        loadInstr(40,  32'h00000000); // NOP
        loadInstr(44,  32'h00000000); // NOP

        // [0x30] label: lw $5, 0($21)
        loadInstr(48,  32'h8EA50000);
        loadInstr(52,  32'h00000000); // NOP
        loadInstr(56,  32'h00000000); // NOP
        loadInstr(60,  32'h00000000); // NOP

        // [0x40] sw $5, 0($22)
        loadInstr(64,  32'hAEC50000);
        loadInstr(68,  32'h00000000); // NOP
        loadInstr(72,  32'h00000000); // NOP
        loadInstr(76,  32'h00000000); // NOP

        // [0x50] addi $21, $21, 4
        loadInstr(80,  32'h22B50004);
        loadInstr(84,  32'h00000000); // NOP
        loadInstr(88,  32'h00000000); // NOP
        loadInstr(92,  32'h00000000); // NOP

        // [0x60] addi $22, $22, 4
        loadInstr(96,  32'h22D60004);
        loadInstr(100, 32'h00000000); // NOP
        loadInstr(104, 32'h00000000); // NOP
        loadInstr(108, 32'h00000000); // NOP

        // [0x70] addi $1, $1, -1
        loadInstr(112, 32'h2021FFFF);
        loadInstr(116, 32'h00000000); // NOP
        loadInstr(120, 32'h00000000); // NOP
        loadInstr(124, 32'h00000000); // NOP

        // [0x80] bne $1, $0, label    -> offset=-21, jumps back to 0x30
        loadInstr(128, 32'h1420FFEB);
        loadInstr(132, 32'h00000000); // NOP
        loadInstr(136, 32'h00000000); // NOP
        loadInstr(140, 32'h00000000); // NOP

        // ------------------------------------------------
        // Run long enough for 4 iterations
        // each iteration = 6 instructions * 4 (instr+NOPs) * 10ns = 240ns
        // + setup = ~100ns, total ~1100ns to be safe
        // ------------------------------------------------
        #2000;

        // ------------------------------------------------
        // Check destination memory: 0x20..0x3F should = DEADBEEF
        // ------------------------------------------------
        $display("=== DESTINATION MEMORY (expect DEADBEEF) ===");
        for (i = 0; i < 32; i = i + 4) begin
            $display("mem[0x%02h..0x%02h] = %h %h %h %h",
                8'h20+i, 8'h20+i+3,
                uut.DMEM.mem[32+i],   uut.DMEM.mem[32+i+1],
                uut.DMEM.mem[32+i+2], uut.DMEM.mem[32+i+3]);
        end

        $display("=== REGISTERS ===");
        $display("$1  = %0d (expect 0)",    uut.REGFILE.regBank[1]);
        $display("$21 = 0x%h (expect 0x20)", uut.REGFILE.regBank[21]);
        $display("$22 = 0x%h (expect 0x40)", uut.REGFILE.regBank[22]);

        #100;
        $finish;
    end

endmodule


/*
ALRIGHT, 

new TB:

force these ocntnets to these locations via TB:
DEADBEEFDEADBEEF 
into 
00 04 08 0c 10 14 18 1c

addi $21, $0, 0 (hex) //source start 
addi $22, $0, 20 (hex) //destination start

addi $1, $0, 4 //represents the number of locations ot be copied

label: lw $5, 0($21)
sw $5, 0($22)

// since it's byte adderssed, incrementing by 4 bytes == incrementing by 1 word
addi $21, $21, 4 
addi $22, $22, 4

addi $1, $1, -1

bne $1, $0, label



*/
