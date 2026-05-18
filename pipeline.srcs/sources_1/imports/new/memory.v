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

module memory #(parameter memorySizeInBytes = 6144, parameter ioWidth = 256)
(
    input  wire        clock, reset,
    input  wire        memWrite, memRead,
    input  wire [31:0] address,
    input  wire [31:0] writeData,
    input  wire [ioWidth-1:0] memMappedIO,
    output reg  [31:0] readData,
    output wire [8191:0] framebuffer
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
    // FB occupies bytes 0x200..0x5FF = 256 words
    // Word w covers pixels [w*32 .. w*32+31]
    // framebuffer[flat] = word_w bit (flat%32), word_w = mem[0x200+w*4..+3]
    // Reconstruct each word big-endian (same as lw) then expose bits
    genvar w;
    generate
        for (w = 0; w < 256; w = w + 1) begin : fb_words
            wire [31:0] fb_word;
            assign fb_word = {mem[32'h200 + w*4],
                              mem[32'h200 + w*4 + 1],
                              mem[32'h200 + w*4 + 2],
                              mem[32'h200 + w*4 + 3]};
            // pixel flat = w*32+b, b=0..31
            // framebuffer bit assignment: fb[w*32+b] = fb_word[b]
            // but fb_word bit ordering: bit31 = mem[w*4] MSB ... bit0 = mem[w*4+3] LSB
            // the program does: mask = 1<<bit_idx, word |= mask
            // so bit_idx 0 = LSB of the word = mem[w*4+3] bit0
            // framebuffer[w*32 + b] = fb_word[b]  (b=0 is LSB)
            assign framebuffer[w*32 +: 32] = fb_word;
        end
    endgenerate

endmodule