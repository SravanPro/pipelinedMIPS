`timescale 1ns / 1ps

module parent #(parameter inputs = 256, parameter SIM_MODE = 0)(
    input clock,  
    input reset,  
    input white, black, brown, red, gameRst, erase, draw,
    input speedInc, speedDec,
    input sw,
    output sck,
    output sda,
    output res,
    output dc,
    output cs,
    output [3:0] speedOut,
    output [6:0] seg0,
    output [6:0] seg1,
    output half_digit
);

    tff TFF (
        .clock(clock),
        .reset(reset),
        .t(1'b1),
        .q(t_ff_clk)
    );

    // stage 1: analog translator (RESTORED)
    wire rightRaw, leftRaw, upRaw, downRaw;
    analogTranslator ANALOG_TRANSLATOR (
        .white(white),
        .black(black),
        .brown(brown),
        .red(red),
        .right(rightRaw),
        .left(leftRaw),
        .up(upRaw),
        .down(downRaw)
    );

    // stage 2: movement divider (WITH SIM_MODE)
    wire right, left, up, down;
    movementDivider #(.SIM_MODE(SIM_MODE)) MOVEMENT_DIVIDER (
        .clock(t_ff_clk),
        .reset(reset),
        .rightRaw(rightRaw),
        .leftRaw(leftRaw),
        .upRaw(upRaw),
        .downRaw(downRaw),
        .speedInc(speedInc),
        .speedDec(speedDec),
        .right(right),
        .left(left),
        .up(up),
        .down(down),
        .speedOut(speedOut)
    );

    wire [31:0] r1;
    wire [31:0] r2;
    wire [inputs-1:0] memMappedIO = {{(inputs-7){1'b0}}, gameRst, erase, draw, down, up, left, right};
    wire [8191:0] framebuffer;

    pipeline #(.inputs(inputs)) PIPELINE (
        .clock         (t_ff_clk),
        .reset       (reset),
        .memMappedIO (memMappedIO),
        .framebuffer (framebuffer),
        .r1(r1), .r2(r2)
    );

    segmentDisplayDecoder SEGMENT_DISPLAY_DECODER (
        .sw(sw),
        .X(r1[6:0]),
        .Y(r2[5:0]),
        .seg0(seg0),
        .seg1(seg1),
        .half_digit(half_digit)
    );

    wire [8191:0] crosshairFB;
    crosshair CROSSHAIR (
        .clock(clock),
        .reset(reset),
        .X(r1),
        .Y(r2),
        .crosshairFB(crosshairFB) 
    );


    wire [8191:0] framebufferNet = framebuffer | crosshairFB;
    spi SPI (
        .clock(t_ff_clk),
        .reset(reset),
        .fb(framebufferNet),
        .sck(sck),
        .sda(sda),
        .res(res),
        .dc(dc),    
        .cs(cs)
    );

endmodule