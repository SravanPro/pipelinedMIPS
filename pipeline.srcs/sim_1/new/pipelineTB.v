`timescale 1ns / 1ps

module pipelineTB();

    reg clock;
    reg reset;

    pipeline uut (
        .clock   (clock),
        .reset (reset)
    );

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

        uut.REGFILE.regBank[1]  = 32'hEDDE4997;
        uut.REGFILE.regBank[2]  = 32'hABAC4155;
        uut.REGFILE.regBank[4]  = 32'hFF77FFFF;
        uut.REGFILE.regBank[5]  = 32'h11FF99FF;
        uut.REGFILE.regBank[7]  = 32'hD1234567;
        uut.REGFILE.regBank[8]  = 32'hC011010E;
        uut.REGFILE.regBank[10] = 32'hEB129099;
        uut.REGFILE.regBank[11] = 32'hA9FF8701;

        loadInstr(0,  32'h00411820);
        loadInstr(4,  32'h00A4302C);
        loadInstr(8,  32'h01074827);
        loadInstr(12, 32'h016A6022);

        #150;

        #10;
        $finish;
    end

endmodule
