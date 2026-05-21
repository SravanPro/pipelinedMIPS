`timescale 1ns / 1ps

/*
  Memory map:
    0x000 - 0x1FF : general data (512 bytes)
    0x200 - 0x5FF : framebuffer (1024 bytes, bit-packed)
      pixel(X,Y) -> flat = Y*128 + X
                    word @ (0x200 + (flat>>5)*4), bit = flat & 31
      framebuffer[flat] = mem_word[flat>>5][flat&31]

  MMIO: address[31:8] == 24'hFFFFFF
    readData = {32{memMappedIO[address[7:0]]}}

  framebuffer output: 8192-bit flat array, framebuffer[Y*128+X] = pixel state
    LSB of each packed word = pixel with lowest flat index
*/

module memory #(parameter memorySizeInBytes = 1024, parameter ioWidth = 256)
(
    input  wire        clock, reset,
    input  wire        memWrite, memRead,
    input  wire [31:0] address,
    input  wire [31:0] writeData,
    input  wire [ioWidth-1:0] memMappedIO,
    output reg  [31:0] readData,
    output reg [8191:0] framebuffer
);

    integer i;
    reg [7:0] mem [memorySizeInBytes-1:0];

    initial begin
        for (i = 0; i < memorySizeInBytes; i = i + 1)
            mem[i] = 8'h00;
    end

    // ---- combinational read ----
    always @(*) begin
        if (memRead) begin
            if (address[31:8] != 24'hFFFFFF) begin
                readData = {mem[address], mem[address+1], mem[address+2], mem[address+3]};
            end else begin
                if (address[7:0] < ioWidth)
                    readData = {32{memMappedIO[address[7:0]]}};
                else
                    readData = 32'b0;
            end
        end else begin
            readData = 32'b0;
        end
    end

    // ---- synchronous write ----
    always @(posedge clock or posedge reset) begin
        if (reset) begin
            for (i = 0; i < memorySizeInBytes; i = i + 1)
                mem[i] <= 8'h00;
        end else begin
            if (memWrite && address[31:8] != 24'hFFFFFF) begin
                mem[address]   <= writeData[31:24];
                mem[address+1] <= writeData[23:16];
                mem[address+2] <= writeData[15:8];
                mem[address+3] <= writeData[7:0];
            end
        end
    end

    // ---- framebuffer output ----
    integer w;
    always @(*) begin
        for (w = 0; w < 256; w = w + 1) begin
            framebuffer[w*32 +: 32] = {mem[w*4],
                                       mem[w*4 + 1],
                                       mem[w*4 + 2],
                                       mem[w*4 + 3]};
        end
    end

endmodule