`timescale 1ns / 1ps

// pipelineTB1 — I-type instruction sequence (addi, ori, lui)
//
// Encodings (MIPS big-endian instruction words):
//   addi r1, r0, 36       -> 0x20010024  (r1 <- 0 + 36 = 36)
//   addi r1, r0, -12      -> 0x2001FFF4  (would set r1 <- 0 + (-12) = -12; NOT used below)
//   addi r1, r1, -12      -> 0x2021FFF4  (r1 <- r1 + (-12); after first addi => 24)
//   ori  r2, r1, 0        -> 0x34420000  (r2 <- r1 | 0 = r1)
//   lui  r3, 0xABAB       -> 0x3C03ABAB  (r3 <- 0xABAB0000)
//   ori  r3, r3, 0xCDCD   -> 0x3463CDCD  (r3 <- 0xABAB0000 | 0x0000CDCD = 0xABABCDCD)
//
// Expected final registers (assuming reset cleared regfile, r0 reads 0):
//   r1 = 32'h00000018 (24)
//   r2 = 32'h00000018 (24)
//   r3 = 32'hABABCDCD
//
// Hazards: consecutive RAW on r1 (addi/addi/ori) and on r3 (lui/ori). Your forwarding
// unit should supply EX/MEM or MEM/WB results to ALU inputs; no load-use stalls here.

module pipelineTB1 ();

    reg clock;
    reg reset;

    pipeline uut (
        .clock   (clock),
        .reset (reset)
    );

    // Waveform probes: $0..$3 only (scope = pipelineTB1)
    wire [31:0] dbg_r0 = uut.REGFILE.regBank[0];
    wire [31:0] dbg_r1 = uut.REGFILE.regBank[1];
    wire [31:0] dbg_r2 = uut.REGFILE.regBank[2];
    wire [31:0] dbg_r3 = uut.REGFILE.regBank[3];

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

        for (i = 0; i < 256; i = i + 1) uut.IMEM.mem[i] = 8'h00;
        for (i = 0; i < 128; i = i + 1) uut.DMEM.mem[i] = 8'h00;

        // Instruction memory @ byte addresses (PC += 4)
        loadInstr(0,  32'h20010024);  // addi r1, r0, 36
        loadInstr(4,  32'h2021FFF4);  // addi r1, r1, -12  -> r1 = 24 (see header for r0,-12 hex)
        loadInstr(8,  32'h34220000);  // ori  r2, r1, 0
        loadInstr(12, 32'h3C03ABAB);  // lui  r3, 0xABAB
        loadInstr(16, 32'h3463CDCD);  // ori  r3, r3, 0xCDCD

        // Enough cycles for 5 instructions through WB (5-stage) + margin
        #200;

        $display("TB1 I-type: r0=%h r1=%h (expect 00000018) r2=%h r3=%h (expect ABABCDCD)",
                 dbg_r0, dbg_r1, dbg_r2, dbg_r3);

        #10;
        $finish;
    end

endmodule

