`timescale 1ns / 1ps

module parent #(parameter inputs = 256, parameter SIM_MODE = 0)(
    input clock,  
    input reset,  
    input white, black, brown, red, gameRst, erase, draw,
    input speedInc, speedDec,
    output wire [8191:0] framebufferNet,
    output [3:0] speedOut
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
        .clock(clock),
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
        .clock         (clock),
        .reset       (reset),
        .memMappedIO (memMappedIO),
        .framebuffer (framebuffer),
        .r1(r1), .r2(r2)
    );

    wire [8191:0] crosshairFB;
    crosshair CROSSHAIR (
        .clock(clock),
        .reset(reset),
        .X(r1),
        .Y(r2),
        .crosshairFB(crosshairFB) 
    );

    assign framebufferNet = framebuffer | crosshairFB;

endmodule
