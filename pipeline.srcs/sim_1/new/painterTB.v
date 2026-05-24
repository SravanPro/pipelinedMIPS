`timescale 1ns / 1ps

module painterTB ();
    reg clock, reset;
    reg draw, erase, gameRst, speedInc, speedDec;
    reg white, black, brown, red;

    
    wire [3:0] speedOut;

    // Change "DMEM" to whatever your data memory instance name is inside PIPELINE
    wire memWrite = uut.PIPELINE.DMEM.memWrite;

    parent #(.inputs(256), .SIM_MODE(1)) uut (
        .clock(clock), .reset(reset),
        .white(white), .black(black), .brown(brown), .red(red),
        .gameRst(gameRst), .erase(erase), .draw(draw),
        .speedInc(speedInc), .speedDec(speedDec),
        .speedOut(speedOut)
    );
    
    wire [8191:0] framebufferNet = uut.framebufferNet;

    always #5 clock = ~clock;

    // File Logging Logic
    integer frame_file, x, y, flat;
    reg prev_memWrite;
    
    initial begin
        prev_memWrite = 0;
        frame_file = $fopen("frames.txt", "w");
        $fclose(frame_file);
    end

    task dump;
        begin
//            $display("DUMP: reset=%b t_ff_clk=%b r1=%h r2=%h crosshair.reset=%b crosshair.step=%0d crosshair.active=%b crosshair_or=%b framebuffer_or=%b", reset, uut.t_ff_clk, uut.r1, uut.r2, uut.CROSSHAIR.reset, uut.CROSSHAIR.step, uut.CROSSHAIR.active, |uut.crosshairFB, |uut.framebuffer);
            frame_file = $fopen("frames.txt", "a");
            for (y = 0; y < 64; y = y + 1) begin
                for (x = 0; x < 128; x = x + 1) begin
                    $fwrite(frame_file, "%0d", framebufferNet[y*128+x]);
                end
                $fwrite(frame_file, "\n");
            end
            $fwrite(frame_file, "========================================\n");
            $fclose(frame_file);
        end
    endtask

    always @(posedge clock) begin
        if (memWrite && !prev_memWrite) dump();
        prev_memWrite <= memWrite;
        // $display("TICK: reset=%b t_ff_clk=%b r1=%h crosshair.step=%0d crosshair.active=%b", reset, uut.t_ff_clk, uut.r1, uut.CROSSHAIR.step, uut.CROSSHAIR.active);
    end

    // Joystick Logic: Maps logical DIR to your specific wire polarities
    task set_joystick(input reg r, input reg l, input reg u, input reg d);
        begin
            white = l;      // High = Left
            brown = d;      // High = Down
            black = ~r;     // Low = Right
            red   = ~u;     // Low = Up
        end
    endtask

    initial begin
        {clock, reset, draw, erase, gameRst, speedInc, speedDec} = 0;
        set_joystick(0,0,0,0);
        
        #1000 reset = 1; #100 reset = 0;
     //   $display("DEBUG_INIT: After reset sequence, reset=%b clock=%b t_ff_clk=%b crosshair.reset=%b crosshair.step=%0d crosshair.active=%b crosshair.Xr=%0d crosshair.Yr=%0d", reset, clock, uut.t_ff_clk, uut.CROSSHAIR.reset, uut.CROSSHAIR.step, uut.CROSSHAIR.active, uut.CROSSHAIR.Xr, uut.CROSSHAIR.Yr);
        repeat(1000) @(posedge clock); // Boot up
      //  $display("DEBUG_BOOT: After 1000 clocks, reset=%b clock=%b t_ff_clk=%b crosshair.step=%0d crosshair.active=%b crosshair_or=%b", reset, clock, uut.t_ff_clk, uut.CROSSHAIR.step, uut.CROSSHAIR.active, |uut.crosshairFB);

        $display("Simulating 32-pixel move (Fast Mode)...");
        draw = 1;
        set_joystick(1, 0, 0, 0); // Move RIGHT
        
        // At SIM_MODE=1, Divider is 1666. 32 pixels * 1666 = 53,312 cycles.
        repeat(55000) @(posedge clock);
        
        set_joystick(0,0,0,0);
        draw = 0;
        
        repeat(500) @(posedge clock);
        $display("Simulation finished. Check frames.txt");
        $finish;
    end
endmodule
