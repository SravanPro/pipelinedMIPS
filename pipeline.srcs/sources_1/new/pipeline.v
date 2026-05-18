`timescale 1ns / 1ps

module pipeline (
    input wire clk,
    input wire reset
);




    wire [31:0] pc_out;
    wire [31:0] pc_plus4;
    wire [31:0] pc_next;
    wire [31:0] if_instruction;

    wire [31:0] if_id_NPC;
    wire [31:0] if_id_IR;
    
    wire [5:0]  id_opcode = if_id_IR[31:26];
    wire [4:0]  id_RS     = if_id_IR[25:21];
    wire [4:0]  id_RT     = if_id_IR[20:16];
    wire [4:0]  id_RD     = if_id_IR[15:11];
    wire [5:0]  id_funct  = if_id_IR[5:0];
    wire [15:0] id_imm16  = if_id_IR[15:0];

    wire        id_regDst, id_aluSrc, id_memToReg;
    wire        id_regWrite, id_memRead, id_memWrite;
    wire        id_branchEq, id_branchNe, id_jump, id_jal;
    wire [3:0]  id_aluOp;

    pc PC (
        .clock    (clk),
        .reset    (reset),
        .pcStall  (1'b0),
        .pcInVal  (pc_next),
        .pcOutVal (pc_out)
    );

    adder PC_ADDER (
        .a   (pc_out),
        .b   (32'd4),
        .sum (pc_plus4)
    );

    instructionMem IMEM (
        .pcVal       (pc_out),
        .instruction (if_instruction)
    );






    if_id IF_ID (
        .clk           (clk),
        .reset         (reset),
        .if_id_stall   (1'b0),
        .if_id_flush   (id_jump),
        .if_id_NPC_in  (pc_plus4),
        .if_id_IR_in   (if_instruction),
        .if_id_NPC_out (if_id_NPC),
        .if_id_IR_out  (if_id_IR)
    );

    wire [31:0] jumpAddress;
    jTypeAddressProcessor JUMP_ADDR_PROC (
        .if_id_IR (if_id_IR),
        .if_id_NPC (if_id_NPC),
        .jumpAddress (jumpAddress)
     );

    wire [31:0] branchMuxOut;

    mux2 #(.width(32)) JUMP_MUX (
        .in0 (branchMuxOut),
        .in1 (jumpAddress),
        .s   (id_jump), // Check if opcode is J
        .out (pc_next)
    );

    




    mainControl CTRL (
        .opCode   (id_opcode),
        .regDst   (id_regDst),
        .aluSrc   (id_aluSrc),
        .memToReg (id_memToReg),
        .regWrite (id_regWrite),
        .memRead  (id_memRead),
        .memWrite (id_memWrite),
        .branchEq (id_branchEq),
        .branchNe (id_branchNe),
        .jump     (id_jump),
        .jal      (id_jal),
        .aluOp    (id_aluOp)
    );

    wire [31:0] id_signImm;
    signExtend SEXT (
        .in  (id_imm16),
        .out (id_signImm)
    );

    wire [31:0] id_zeroImm;
    zeroExtend ZEXT (
        .in  (id_imm16),
        .out (id_zeroImm)
    );

    wire [31:0] id_imm;
    wire id_immSelect;
    sext_or_zext_control SEXT_OR_ZEXT_CTRL (
        .aluOp (id_aluOp),
        .sext_or_zext (id_immSelect)
    );
    
    mux2 #(.width(32)) IMM_MUX (
        .in0 (id_signImm),
        .in1 (id_zeroImm),
        .s   (id_immSelect),
        .out (id_imm)
    );

    wire [31:0] mem_wb_NPC;
    wire        wb_regWrite;
    wire [4:0]  wb_regDest;
    wire [31:0] wb_writeData;
    wire [31:0] wb_writeData_final;

    wire [31:0] mem_wb_LMD;
    wire [31:0] mem_wb_AluOut;
    wire [4:0]  mem_wb_RD;
    wire        mem_wb_RegWrite, mem_wb_MemToReg;
    wire        mem_wb_Jal;


    wire [31:0] id_rd1, id_rd2;
    regFile REGFILE (
        .clock    (clk),
        .reset    (reset),
        .regWrite (wb_regWrite),
        .rn1      (id_RS),
        .rn2      (id_RT),
        .wn       (wb_regDest),
        .wd       (wb_writeData_final),
        .rd1      (id_rd1),
        .rd2      (id_rd2)
    );




    wire [31:0] id_ex_NPC;
    wire [31:0] id_ex_A,   id_ex_B;
    wire [31:0] id_ex_Imm;
    wire [4:0]  id_ex_RS,  id_ex_RT,  id_ex_RD;
    wire        id_ex_RegDst, id_ex_ALUSrc;
    wire [3:0]  id_ex_ALUOp;
    wire        id_ex_BranchEq, id_ex_BranchNe;
    wire        id_ex_MemRead, id_ex_MemWrite;
    wire        id_ex_RegWrite, id_ex_MemToReg;
    wire        id_ex_Jal;


    id_ex ID_EX (
        .clk                (clk),
        .reset              (reset),
        .id_ex_stall        (1'b0),
        .id_ex_NPC_in       (if_id_NPC),
        .id_ex_A_in         (id_rd1),
        .id_ex_B_in         (id_rd2),
        .id_ex_Imm_in       (id_imm),
        .id_ex_RS_in        (id_RS),
        .id_ex_RT_in        (id_RT),
        .id_ex_RD_in        (id_RD),
        .id_ex_RegDst_in    (id_regDst),
        .id_ex_ALUSrc_in    (id_aluSrc),
        .id_ex_ALUOp_in     (id_aluOp),
        .id_ex_BranchEq_in  (id_branchEq),
        .id_ex_BranchNe_in  (id_branchNe),
        .id_ex_MemRead_in   (id_memRead),
        .id_ex_MemWrite_in  (id_memWrite),
        .id_ex_RegWrite_in  (id_regWrite),
        .id_ex_MemToReg_in  (id_memToReg),
        .id_ex_Jal_in       (id_jal),
        .id_ex_NPC_out      (id_ex_NPC),
        .id_ex_A_out        (id_ex_A),
        .id_ex_B_out        (id_ex_B),
        .id_ex_Imm_out      (id_ex_Imm),
        .id_ex_RS_out       (id_ex_RS),
        .id_ex_RT_out       (id_ex_RT),
        .id_ex_RD_out       (id_ex_RD),
        .id_ex_RegDst_out   (id_ex_RegDst),
        .id_ex_ALUSrc_out   (id_ex_ALUSrc),
        .id_ex_ALUOp_out    (id_ex_ALUOp),
        .id_ex_BranchEq_out (id_ex_BranchEq),
        .id_ex_BranchNe_out (id_ex_BranchNe),
        .id_ex_MemRead_out  (id_ex_MemRead),
        .id_ex_MemWrite_out (id_ex_MemWrite),
        .id_ex_RegWrite_out (id_ex_RegWrite),
        .id_ex_MemToReg_out (id_ex_MemToReg),
        .id_ex_Jal_out      (id_ex_Jal)
    );



    wire [31:0] ex_mem_NPC;
    wire [1:0]  forwardA, forwardB;
    wire [31:0] forwardMuxA_out, forwardMuxB_out;
    wire [31:0] ex_mem_BranchTarget;
    wire        ex_mem_Zero;
    wire [31:0] ex_mem_AluOut;
    wire [31:0] ex_mem_B;
    wire [4:0]  ex_mem_RD;
    wire        ex_mem_BranchEq, ex_mem_BranchNe;
    wire        ex_mem_MemRead, ex_mem_MemWrite;
    wire        ex_mem_RegWrite, ex_mem_MemToReg;
    wire        ex_mem_Jal;


    forwardingUnit FORWARD_UNIT (
        .id_ex_RS        (id_ex_RS),
        .id_ex_RT        (id_ex_RT),
        .ex_mem_RegWrite (ex_mem_RegWrite),
        .ex_mem_RD       (ex_mem_RD),
        .mem_wb_RegWrite (mem_wb_RegWrite),
        .mem_wb_RD       (mem_wb_RD),
        .forwardMuxASelect   (forwardA),
        .forwardMuxBSelect   (forwardB)
    );

    mux4 #(.width(32)) FORWARD_MUX_A (
        .in0 (id_ex_A),
        .in1 (wb_writeData_final),
        .in2 (ex_mem_AluOut),
        .in3 (32'b0),
        .s   (forwardA),
        .out (forwardMuxA_out)
    );

    mux4 #(.width(32)) FORWARD_MUX_B (
        .in0 (id_ex_B),
        .in1 (wb_writeData_final),
        .in2 (ex_mem_AluOut),
        .in3 (32'b0),
        .s   (forwardB),
        .out (forwardMuxB_out)
    );

    wire [4:0]  ex_regDest;
    mux2 #(.width(5)) REGDST_MUX (
        .in0 (id_ex_RT),
        .in1 (id_ex_RD),
        .s   (id_ex_RegDst),
        .out (ex_regDest)
    );

    wire [4:0] ex_regDest_final;
    mux2 #(.width(5)) JAL_REGDST_MUX (
        .in0 (ex_regDest),
        .in1 (5'd31),
        .s   (id_ex_Jal),
        .out (ex_regDest_final)
    );

    wire [31:0] ex_aluB;
    mux2 #(.width(32)) ALUSRC_MUX (
        .in0 (forwardMuxB_out),
        .in1 (id_ex_Imm),
        .s   (id_ex_ALUSrc),
        .out (ex_aluB)
    );

    wire [3:0]  ex_aluOp;
    aluControl ALU_CTRL (
        .aluOp (id_ex_ALUOp),
        .func  (id_ex_Imm[5:0]),
        .op    (ex_aluOp)
    );

    wire [31:0] ex_aluResult;
    wire        ex_zero;
    alu ALU (
        .a      (forwardMuxA_out),
        .b      (ex_aluB),
        .op     (ex_aluOp),
        .result (ex_aluResult),
        .zero   (ex_zero)
    );

    wire [31:0] ex_shiftedImm;
    wire [31:0] ex_branchTarget;
    shiftLeft2 SL2 (
        .in  (id_ex_Imm),
        .out (ex_shiftedImm)
    );

    adder BRANCH_ADDER (
        .a   (id_ex_NPC),
        .b   (ex_shiftedImm),
        .sum (ex_branchTarget)
    );

    ex_mem EX_MEM (
        .clk                     (clk),
        .reset                   (reset),
        .ex_mem_NPC_in      (id_ex_NPC),

        .ex_mem_BranchTarget_in  (ex_branchTarget),
        .ex_mem_Zero_in          (ex_zero),
        .ex_mem_AluOut_in        (ex_aluResult),
        .ex_mem_B_in             (forwardMuxB_out),
        .ex_mem_RD_in       (ex_regDest_final),
        .ex_mem_BranchEq_in      (id_ex_BranchEq),
        .ex_mem_BranchNe_in      (id_ex_BranchNe),
        .ex_mem_MemRead_in       (id_ex_MemRead),
        .ex_mem_MemWrite_in      (id_ex_MemWrite),
        .ex_mem_RegWrite_in      (id_ex_RegWrite),
        .ex_mem_MemToReg_in      (id_ex_MemToReg),
        .ex_mem_Jal_in      (id_ex_Jal),

        .ex_mem_NPC_out         (ex_mem_NPC),
        .ex_mem_BranchTarget_out (ex_mem_BranchTarget),
        .ex_mem_Zero_out         (ex_mem_Zero),
        .ex_mem_AluOut_out       (ex_mem_AluOut),
        .ex_mem_B_out            (ex_mem_B),
        .ex_mem_RD_out      (ex_mem_RD),
        .ex_mem_BranchEq_out     (ex_mem_BranchEq),
        .ex_mem_BranchNe_out     (ex_mem_BranchNe),
        .ex_mem_MemRead_out      (ex_mem_MemRead),
        .ex_mem_MemWrite_out     (ex_mem_MemWrite),
        .ex_mem_RegWrite_out     (ex_mem_RegWrite),
        .ex_mem_MemToReg_out     (ex_mem_MemToReg),
        .ex_mem_Jal_out      (ex_mem_Jal)
    );




    wire mem_PCSrc;
    assign mem_PCSrc = (ex_mem_BranchEq & ex_mem_Zero) | (ex_mem_BranchNe & ~ex_mem_Zero);

    mux2 #(.width(32)) PC_MUX (
        .in0 (pc_plus4),
        .in1 (ex_mem_BranchTarget),
        .s   (mem_PCSrc),
        .out (branchMuxOut)
    );

    wire [31:0] mem_readData;
    memory DMEM (
        .clock     (clk),
        .reset     (reset),
        .memWrite  (ex_mem_MemWrite),
        .memRead   (ex_mem_MemRead),
        .address   (ex_mem_AluOut),
        .writeData (ex_mem_B),
        .readData  (mem_readData)
    );


    mem_wb MEM_WB (
        .clk                (clk),
        .reset              (reset),
        .mem_wb_NPC_in      (ex_mem_NPC),

        .mem_wb_LMD_in      (mem_readData),
        .mem_wb_AluOut_in   (ex_mem_AluOut),
        .mem_wb_RD_in  (ex_mem_RD),
        .mem_wb_RegWrite_in (ex_mem_RegWrite),
        .mem_wb_MemToReg_in (ex_mem_MemToReg),
        .mem_wb_Jal_in      (ex_mem_Jal),

        .mem_wb_NPC_out     (mem_wb_NPC),

        .mem_wb_LMD_out     (mem_wb_LMD),
        .mem_wb_AluOut_out  (mem_wb_AluOut),
        .mem_wb_RD_out (mem_wb_RD),
        .mem_wb_RegWrite_out(mem_wb_RegWrite),
        .mem_wb_MemToReg_out(mem_wb_MemToReg),
        .mem_wb_Jal_out     (mem_wb_Jal)
    );




    mux2 #(.width(32)) MEMTOREG_MUX (
        .in0 (mem_wb_AluOut),
        .in1 (mem_wb_LMD),
        .s   (mem_wb_MemToReg),
        .out (wb_writeData)
    );

    mux2 #(.width(32)) JAL_MEMTOREG_MUX (
        .in0 (wb_writeData),
        .in1 (mem_wb_NPC),
        .s   (mem_wb_Jal),
        .out (wb_writeData_final)
    );

    assign wb_regWrite = mem_wb_RegWrite;
    assign wb_regDest  = mem_wb_RD;

endmodule
