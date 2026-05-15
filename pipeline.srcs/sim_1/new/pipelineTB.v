`timescale 1ns / 1ps

module pipelineTB();

    reg clk;
    reg reset;

    pipeline uut (
        .clk   (clk),
        .reset (reset)
    );

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

    integer i;

    initial begin
        clk   = 0;
        reset = 1;
        #17;
        reset = 0;
        #1;

        for (i = 0; i < 128; i = i + 1) uut.IMEM.mem[i] = 8'h00;
        for (i = 0; i < 128; i = i + 1) uut.DMEM.mem[i] = 8'h00;

        uut.REGFILE.regBank[1]  = 32'h00000005;  // $1 = 5
        uut.REGFILE.regBank[2]  = 32'h00000003;  // $2 = 3
        uut.REGFILE.regBank[3]  = 32'h00000000;  // $3 = 0
        uut.REGFILE.regBank[8]  = 32'h000000AA;  // $8 = 0xAA
        uut.REGFILE.regBank[9]  = 32'h000000BB;  // $9 = 0xBB

        uut.DMEM.mem[12] = 8'h00;
        uut.DMEM.mem[13] = 8'h00;
        uut.DMEM.mem[14] = 8'h00;
        uut.DMEM.mem[15] = 8'hCC;

        // [0x00] ADD $4, $1, $2  -> $4 = 8
        loadInstr(0,  32'h00222020);
        // [0x04] SUB $5, $1, $2  -> $5 = 2  (no dependency on ADD)
        loadInstr(4,  32'h00222822);
        // [0x08] AND $6, $1, $2  -> $6 = 1  (no dependency)
        loadInstr(8,  32'h00223024);
        // [0x0C] OR  $7, $1, $2  -> $7 = 7  (no dependency)
        loadInstr(12, 32'h00223825);
        // [0x10] SW  $1, 8($3)   -> mem[8] = 5  (no dependency)
        loadInstr(16, 32'hAC610008);
        // [0x14] LW  $10, 12($3) -> $10 = 0xCC  (no dependency)
        loadInstr(20, 32'h8C6A000C);
        // [0x18] BEQ $8, $9, 1   -> not taken ($8 != $9), no dependency
        loadInstr(24, 32'h11090001);
        // [0x1C] NOP - in branch delay (fetched speculatively, harmless)
        loadInstr(28, 32'h00000000);
        // [0x20] NOP
        loadInstr(32, 32'h00000000);
        // [0x24] NOP
        loadInstr(36, 32'h00000000);
        // [0x28] BEQ $0, $0, -x  -> always taken, loops somewhere back
        loadInstr(40, 32'h1000FFF8);

        #500;

        $display("=== REGISTER FILE ===");
        $display("$4  = %0d (expect 8)",           uut.REGFILE.regBank[4]);
        $display("$5  = %0d (expect 2)",           uut.REGFILE.regBank[5]);
        $display("$6  = %0d (expect 1)",           uut.REGFILE.regBank[6]);
        $display("$7  = %0d (expect 7)",           uut.REGFILE.regBank[7]);
        $display("$10 = 0x%h (expect 0x000000cc)", uut.REGFILE.regBank[10]);

        $display("=== DATA MEMORY ===");
        $display("mem[8..11] = %h %h %h %h (expect 00 00 00 05)",
            uut.DMEM.mem[8], uut.DMEM.mem[9],
            uut.DMEM.mem[10], uut.DMEM.mem[11]);

        #100;
        $finish;
    end

endmodule