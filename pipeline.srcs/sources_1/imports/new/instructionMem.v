`timescale 1ns / 1ps

module instructionMem #(parameter instructionMemSizeInBytes = 1024)
(
    input             reset,
    input      [31:0] pcVal,
    output     [31:0] instruction
);

    reg [7:0] mem [instructionMemSizeInBytes-1 : 0];

    assign instruction = {mem[pcVal], mem[pcVal+1], mem[pcVal+2], mem[pcVal+3]};

    // -----------------------------------------------------------------------
    // Load the painter program whenever reset is asserted.
    // All other state (DMEM, registers, PC) is cleared by the pipeline reset;
    // IMEM is intentionally left with this fixed program so it survives reset.
    // -----------------------------------------------------------------------
    task load_program;
        integer i;
        begin
            for (i = 0; i < instructionMemSizeInBytes; i = i + 1)
                mem[i] = 8'h00;

            // ==============================================================
            // PAINTER PROGRAM
            //
            // Register map:
            //   r1=X  r2=Y  r3=flat  r4=word_idx  r5=bit_idx
            //   r6=FB_word_addr  r7=word  r8=mask  r9=result
            //   r10=MMIO_BASE  r11=scratch
            //   r12=right r13=left r14=up r15=down r16=draw r17=erase r18=game_reset
            //   r19=FB_BASE(0x200)  r20=shift-amount scratch
            //
            // Framebuffer layout in DMEM 0x200..0x5FF (bit-packed):
            //   pixel(X,Y): flat = Y*128 + X
            //   word addr  = 0x200 + (flat>>5)*4
            //   bit index  = flat & 31  (bit0 = LSB)
            // ==============================================================

            // --- INIT (addr 0) ---
            mem[  0]=8'h3C; mem[  1]=8'h0A; mem[  2]=8'hFF; mem[  3]=8'hFF; // lui  r10, 0xFFFF
            mem[  4]=8'h35; mem[  5]=8'h4A; mem[  6]=8'hFF; mem[  7]=8'h00; // ori  r10, r10, 0xFF00  -> MMIO base
            mem[  8]=8'h20; mem[  9]=8'h01; mem[ 10]=8'h00; mem[ 11]=8'h40; // addi r1, r0, 64       X=64
            mem[ 12]=8'h20; mem[ 13]=8'h02; mem[ 14]=8'h00; mem[ 15]=8'h20; // addi r2, r0, 32       Y=32
            mem[ 16]=8'h20; mem[ 17]=8'h13; mem[ 18]=8'h02; mem[ 19]=8'h00; // addi r19, r0, 0x200   FB_BASE

            // --- LOOP (addr 20): latch all buttons ---
            mem[ 20]=8'h8D; mem[ 21]=8'h4C; mem[ 22]=8'h00; mem[ 23]=8'h00; // lw r12, 0(r10)  right
            mem[ 24]=8'h8D; mem[ 25]=8'h4D; mem[ 26]=8'h00; mem[ 27]=8'h01; // lw r13, 1(r10)  left
            mem[ 28]=8'h8D; mem[ 29]=8'h4E; mem[ 30]=8'h00; mem[ 31]=8'h02; // lw r14, 2(r10)  up
            mem[ 32]=8'h8D; mem[ 33]=8'h4F; mem[ 34]=8'h00; mem[ 35]=8'h03; // lw r15, 3(r10)  down
            mem[ 36]=8'h8D; mem[ 37]=8'h50; mem[ 38]=8'h00; mem[ 39]=8'h04; // lw r16, 4(r10)  draw
            mem[ 40]=8'h8D; mem[ 41]=8'h51; mem[ 42]=8'h00; mem[ 43]=8'h05; // lw r17, 5(r10)  erase
            mem[ 44]=8'h8D; mem[ 45]=8'h52; mem[ 46]=8'h00; mem[ 47]=8'h06; // lw r18, 6(r10)  game_reset
            
            //  opti1
//            mem[ 48]=8'h00; mem[ 49]=8'h00; mem[ 50]=8'h00; mem[ 51]=8'h00; // nop
//            mem[ 52]=8'h00; mem[ 53]=8'h00; mem[ 54]=8'h00; mem[ 55]=8'h00; // nop
//            mem[ 56]=8'h00; mem[ 57]=8'h00; mem[ 58]=8'h00; mem[ 59]=8'h00; // nop

            // game_reset check
            mem[ 60]=8'h12; mem[ 61]=8'h40; mem[ 62]=8'h00; mem[ 63]=8'h04; // beq r18, r0, skip_greset (+4 -> 80)
            mem[ 64]=8'h00; mem[ 65]=8'h00; mem[ 66]=8'h00; mem[ 67]=8'h00; // nop
            mem[ 68]=8'h00; mem[ 69]=8'h00; mem[ 70]=8'h00; mem[ 71]=8'h00; // nop
            mem[ 72]=8'h00; mem[ 73]=8'h00; mem[ 74]=8'h00; mem[ 75]=8'h00; // nop
            mem[ 76]=8'h08; mem[ 77]=8'h00; mem[ 78]=8'h00; mem[ 79]=8'h00; // j INIT -> 0
            // skip_greset = 80

            // RIGHT
            mem[ 80]=8'h11; mem[ 81]=8'h80; mem[ 82]=8'h00; mem[ 83]=8'h0C; // beq r12, r0, skip_right (+12 -> 132)
            mem[ 84]=8'h00; mem[ 85]=8'h00; mem[ 86]=8'h00; mem[ 87]=8'h00; // nop
            mem[ 88]=8'h00; mem[ 89]=8'h00; mem[ 90]=8'h00; mem[ 91]=8'h00; // nop
            mem[ 92]=8'h00; mem[ 93]=8'h00; mem[ 94]=8'h00; mem[ 95]=8'h00; // nop
            mem[ 96]=8'h28; mem[ 97]=8'h2B; mem[ 98]=8'h00; mem[ 99]=8'h7F; // slti r11, r1, 127
            
            // opti2
//            mem[100]=8'h00; mem[101]=8'h00; mem[102]=8'h00; mem[103]=8'h00; // nop
//            mem[104]=8'h00; mem[105]=8'h00; mem[106]=8'h00; mem[107]=8'h00; // nop
//            mem[108]=8'h00; mem[109]=8'h00; mem[110]=8'h00; mem[111]=8'h00; // nop

            mem[112]=8'h11; mem[113]=8'h60; mem[114]=8'h00; mem[115]=8'h04; // beq r11, r0, skip_right (+4 -> 132)
            mem[116]=8'h00; mem[117]=8'h00; mem[118]=8'h00; mem[119]=8'h00; // nop
            mem[120]=8'h00; mem[121]=8'h00; mem[122]=8'h00; mem[123]=8'h00; // nop
            mem[124]=8'h00; mem[125]=8'h00; mem[126]=8'h00; mem[127]=8'h00; // nop
            mem[128]=8'h20; mem[129]=8'h21; mem[130]=8'h00; mem[131]=8'h01; // addi r1, r1, 1
            // skip_right = 132

            // LEFT
            mem[132]=8'h11; mem[133]=8'hA0; mem[134]=8'h00; mem[135]=8'h08; // beq r13, r0, skip_left (+8 -> 168)
            mem[136]=8'h00; mem[137]=8'h00; mem[138]=8'h00; mem[139]=8'h00; // nop
            mem[140]=8'h00; mem[141]=8'h00; mem[142]=8'h00; mem[143]=8'h00; // nop
            mem[144]=8'h00; mem[145]=8'h00; mem[146]=8'h00; mem[147]=8'h00; // nop
            mem[148]=8'h10; mem[149]=8'h20; mem[150]=8'h00; mem[151]=8'h04; // beq r1, r0, skip_left (+4 -> 168)
            mem[152]=8'h00; mem[153]=8'h00; mem[154]=8'h00; mem[155]=8'h00; // nop
            mem[156]=8'h00; mem[157]=8'h00; mem[158]=8'h00; mem[159]=8'h00; // nop
            mem[160]=8'h00; mem[161]=8'h00; mem[162]=8'h00; mem[163]=8'h00; // nop
            mem[164]=8'h20; mem[165]=8'h21; mem[166]=8'hFF; mem[167]=8'hFF; // addi r1, r1, -1
            // skip_left = 168

            // UP
            mem[168]=8'h11; mem[169]=8'hC0; mem[170]=8'h00; mem[171]=8'h0C; // beq r14, r0, skip_up (+12 -> 220)
            mem[172]=8'h00; mem[173]=8'h00; mem[174]=8'h00; mem[175]=8'h00; // nop
            mem[176]=8'h00; mem[177]=8'h00; mem[178]=8'h00; mem[179]=8'h00; // nop
            mem[180]=8'h00; mem[181]=8'h00; mem[182]=8'h00; mem[183]=8'h00; // nop
            mem[184]=8'h28; mem[185]=8'h4B; mem[186]=8'h00; mem[187]=8'h3F; // slti r11, r2, 63
            
            //opti3
//            mem[188]=8'h00; mem[189]=8'h00; mem[190]=8'h00; mem[191]=8'h00; // nop
//            mem[192]=8'h00; mem[193]=8'h00; mem[194]=8'h00; mem[195]=8'h00; // nop
//            mem[196]=8'h00; mem[197]=8'h00; mem[198]=8'h00; mem[199]=8'h00; // nop

            mem[200]=8'h11; mem[201]=8'h60; mem[202]=8'h00; mem[203]=8'h04; // beq r11, r0, skip_up (+4 -> 220)
            mem[204]=8'h00; mem[205]=8'h00; mem[206]=8'h00; mem[207]=8'h00; // nop
            mem[208]=8'h00; mem[209]=8'h00; mem[210]=8'h00; mem[211]=8'h00; // nop
            mem[212]=8'h00; mem[213]=8'h00; mem[214]=8'h00; mem[215]=8'h00; // nop
            mem[216]=8'h20; mem[217]=8'h42; mem[218]=8'h00; mem[219]=8'h01; // addi r2, r2, 1
            // skip_up = 220

            // DOWN
            mem[220]=8'h11; mem[221]=8'hE0; mem[222]=8'h00; mem[223]=8'h08; // beq r15, r0, skip_down (+8 -> 256)
            mem[224]=8'h00; mem[225]=8'h00; mem[226]=8'h00; mem[227]=8'h00; // nop
            mem[228]=8'h00; mem[229]=8'h00; mem[230]=8'h00; mem[231]=8'h00; // nop
            mem[232]=8'h00; mem[233]=8'h00; mem[234]=8'h00; mem[235]=8'h00; // nop
            mem[236]=8'h10; mem[237]=8'h40; mem[238]=8'h00; mem[239]=8'h04; // beq r2, r0, skip_down (+4 -> 256)
            mem[240]=8'h00; mem[241]=8'h00; mem[242]=8'h00; mem[243]=8'h00; // nop
            mem[244]=8'h00; mem[245]=8'h00; mem[246]=8'h00; mem[247]=8'h00; // nop
            mem[248]=8'h00; mem[249]=8'h00; mem[250]=8'h00; mem[251]=8'h00; // nop
            mem[252]=8'h20; mem[253]=8'h42; mem[254]=8'hFF; mem[255]=8'hFF; // addi r2, r2, -1
            // skip_down = 256

            // Compute framebuffer address
            mem[256]=8'h20; mem[257]=8'h14; mem[258]=8'h00; mem[259]=8'h07; // addi r20, r0, 7
            mem[272]=8'h02; mem[273]=8'h82; mem[274]=8'h18; mem[275]=8'h04; // sllv r3, r2, r20      r3 = Y<<7
            mem[288]=8'h00; mem[289]=8'h61; mem[290]=8'h18; mem[291]=8'h20; // add  r3, r3, r1       r3 = flat
            mem[304]=8'h20; mem[305]=8'h14; mem[306]=8'h00; mem[307]=8'h05; // addi r20, r0, 5
            mem[320]=8'h02; mem[321]=8'h83; mem[322]=8'h20; mem[323]=8'h06; // srlv r4, r3, r20      r4 = word_idx
            mem[336]=8'h30; mem[337]=8'h65; mem[338]=8'h00; mem[339]=8'h1F; // andi r5, r3, 31       r5 = bit_idx
            mem[352]=8'h20; mem[353]=8'h14; mem[354]=8'h00; mem[355]=8'h02; // addi r20, r0, 2
            mem[368]=8'h02; mem[369]=8'h84; mem[370]=8'h30; mem[371]=8'h04; // sllv r6, r4, r20      r6 = word_idx*4
            mem[384]=8'h00; mem[385]=8'hD3; mem[386]=8'h30; mem[387]=8'h20; // add  r6, r6, r19      r6 = FB word addr
            mem[400]=8'h8C; mem[401]=8'hC7; mem[402]=8'h00; mem[403]=8'h00; // lw   r7, 0(r6)        current word
            mem[416]=8'h20; mem[417]=8'h08; mem[418]=8'h00; mem[419]=8'h01; // addi r8, r0, 1
            mem[432]=8'h00; mem[433]=8'hA8; mem[434]=8'h40; mem[435]=8'h04; // sllv r8, r8, r5       r8 = 1<<bit_idx


            // DRAW
            mem[448]=8'h12; mem[449]=8'h00; mem[450]=8'h00; mem[451]=8'h08; // beq r16, r0, skip_draw (+8 -> 484)
            mem[452]=8'h00; mem[453]=8'h00; mem[454]=8'h00; mem[455]=8'h00; // nop
            mem[456]=8'h00; mem[457]=8'h00; mem[458]=8'h00; mem[459]=8'h00; // nop
            mem[460]=8'h00; mem[461]=8'h00; mem[462]=8'h00; mem[463]=8'h00; // nop
            mem[464]=8'h00; mem[465]=8'hE8; mem[466]=8'h48; mem[467]=8'h25; // or   r9, r7, r8
            mem[480]=8'hAC; mem[481]=8'hC9; mem[482]=8'h00; mem[483]=8'h00; // sw   r9, 0(r6)
            // skip_draw = 484

            // ERASE
            mem[484]=8'h12; mem[485]=8'h20; mem[486]=8'h00; mem[487]=8'h0C; // beq r17, r0, skip_erase (+12 -> 536)
            mem[488]=8'h00; mem[489]=8'h00; mem[490]=8'h00; mem[491]=8'h00; // nop
            mem[492]=8'h00; mem[493]=8'h00; mem[494]=8'h00; mem[495]=8'h00; // nop
            mem[496]=8'h00; mem[497]=8'h00; mem[498]=8'h00; mem[499]=8'h00; // nop
            mem[500]=8'h01; mem[501]=8'h00; mem[502]=8'h40; mem[503]=8'h27; // nor  r8, r8, r0        r8 = ~r8
            mem[516]=8'h00; mem[517]=8'hE8; mem[518]=8'h48; mem[519]=8'h24; // and  r9, r7, r8
            mem[532]=8'hAC; mem[533]=8'hC9; mem[534]=8'h00; mem[535]=8'h00; // sw   r9, 0(r6)
            // skip_erase = 536

            // Back to LOOP
            mem[536]=8'h08; mem[537]=8'h00; mem[538]=8'h00; mem[539]=8'h05; // j LOOP -> 20
        end
    endtask

    // Load on power-up
    initial load_program;

    // Reload on every reset assertion so the program survives a hardware reset
    always @(posedge reset) load_program;

endmodule