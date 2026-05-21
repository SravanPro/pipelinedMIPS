`timescale 1ns / 1ps
module pipelineTB2 ();
    reg clock;
    reg reset;
    reg [1:0] mmio_in;

    pipeline #(.inputs(2)) uut (
        .clock         (clock),
        .reset       (reset),
        .memMappedIO (mmio_in)
    );

    wire [31:0] dbg_r1 = uut.REGFILE.regBank[1];
    wire [31:0] dbg_r2 = uut.REGFILE.regBank[2];
    wire [31:0] dbg_r7 = uut.REGFILE.regBank[7];
    wire [31:0] dbg_r9 = uut.REGFILE.regBank[9];

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
        clock     = 0;
        reset   = 1;
        mmio_in = 2'b01;

        // -------------------------------------------------
        // Zero memories and load program WHILE reset is high
        // so the pipeline never fetches an X instruction
        // -------------------------------------------------
        #2; // let sim settle, still in reset
        for (i = 0; i < 256; i = i + 1) uut.IMEM.mem[i] = 8'h00;
        for (i = 0; i < 512; i = i + 1) uut.DMEM.mem[i] = 8'h00;

        // lui  r7, 0xFFFF      -> r7 = 0xFFFF0000
        loadInstr(0,  32'h3C07FFFF);
        
        // ori  r7, r7, 0xFF00  -> r7 = 0xFFFFFF00
        loadInstr(4,  32'h34E7FF00);
        
        // lui  r9, 0xFFFF      -> r9 = 0xFFFF0000
        loadInstr(8,  32'h3C09FFFF);
        
        // ori  r9, r9, 0xFF01  -> r9 = 0xFFFFFF01
        loadInstr(12, 32'h3529FF01);
        
        // lw   r1, 0(r7)       -> r1 = mem[0xFFFFFF00] = FFFFFFFF (mmio bit0=1)
        loadInstr(16, 32'h8CE10000);
        
        // lw   r2, 0(r9)       -> r2 = mem[0xFFFFFF01] = FFFFFFFF (mmio bit1=1)
        loadInstr(20, 32'h8D220000);
        

        // -------------------------------------------------
        // Now deassert reset - pipeline starts clean
        // -------------------------------------------------
        #15;
        reset = 0;

        #300;
        $finish;
    end
endmodule




