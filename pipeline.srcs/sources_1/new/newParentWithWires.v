`timescale 1ns / 1ps

// newParentWithWires
// ------------------------------------------------------------
// Wraps the full pipeline and exposes every internal signal as
// a top-level port so Vivado cannot optimize away the data
// memory (512 B), instruction memory (256 B), or register file
// (32 x 32-bit registers).
//
// Pin naming convention:
//   o_<signal>  - output from this module (driven by pipeline)
//   i_<signal>  - input  to  this module (fed into pipeline)
// ------------------------------------------------------------

module newParentWithWires (

    // --------------------------------------------------------
    // Primary clock / reset
    // --------------------------------------------------------
    input  wire        clock,
    input  wire        reset,

    // --------------------------------------------------------
    // IF stage
    // --------------------------------------------------------
    output wire [31:0] o_pc_out,
    output wire [31:0] o_pc_plus4,
    output wire [31:0] o_pc_next,
    output wire [31:0] o_if_instruction,

    // --------------------------------------------------------
    // IF/ID pipeline register outputs
    // --------------------------------------------------------
    output wire [31:0] o_if_id_NPC,
    output wire [31:0] o_if_id_IR,

    // --------------------------------------------------------
    // ID stage - decoded instruction fields
    // --------------------------------------------------------
    output wire [5:0]  o_id_opcode,
    output wire [4:0]  o_id_RS,
    output wire [4:0]  o_id_RT,
    output wire [4:0]  o_id_RD,
    output wire [5:0]  o_id_funct,
    output wire [15:0] o_id_imm16,

    // --------------------------------------------------------
    // ID stage - control signals
    // --------------------------------------------------------
    output wire        o_id_regDst,
    output wire        o_id_aluSrc,
    output wire        o_id_memToReg,
    output wire        o_id_regWrite,
    output wire        o_id_memRead,
    output wire        o_id_memWrite,
    output wire        o_id_branchEq,
    output wire        o_id_branchNe,
    output wire        o_id_jump,
    output wire [3:0]  o_id_aluOp,

    // --------------------------------------------------------
    // ID stage - immediate / register-file outputs
    // --------------------------------------------------------
    output wire [31:0] o_id_signImm,
    output wire [31:0] o_id_zeroImm,
    output wire [1:0]  o_id_immSelect,
    output wire [31:0] o_id_imm,
    output wire [31:0] o_id_rd1,
    output wire [31:0] o_id_rd2,

    // --------------------------------------------------------
    // Register file - full 32-register read-back bus
    // (one output port per register so nothing is trimmed)
    // --------------------------------------------------------
    output wire [31:0] o_reg00,
    output wire [31:0] o_reg01,
    output wire [31:0] o_reg02,
    output wire [31:0] o_reg03,
    output wire [31:0] o_reg04,
    output wire [31:0] o_reg05,
    output wire [31:0] o_reg06,
    output wire [31:0] o_reg07,
    output wire [31:0] o_reg08,
    output wire [31:0] o_reg09,
    output wire [31:0] o_reg10,
    output wire [31:0] o_reg11,
    output wire [31:0] o_reg12,
    output wire [31:0] o_reg13,
    output wire [31:0] o_reg14,
    output wire [31:0] o_reg15,
    output wire [31:0] o_reg16,
    output wire [31:0] o_reg17,
    output wire [31:0] o_reg18,
    output wire [31:0] o_reg19,
    output wire [31:0] o_reg20,
    output wire [31:0] o_reg21,
    output wire [31:0] o_reg22,
    output wire [31:0] o_reg23,
    output wire [31:0] o_reg24,
    output wire [31:0] o_reg25,
    output wire [31:0] o_reg26,
    output wire [31:0] o_reg27,
    output wire [31:0] o_reg28,
    output wire [31:0] o_reg29,
    output wire [31:0] o_reg30,
    output wire [31:0] o_reg31,

    // --------------------------------------------------------
    // Instruction memory - full 256-byte read-back bus
    // (8-bit byte ports, 256 entries = 64 words)
    // --------------------------------------------------------
    output wire [7:0]  o_imem_b000, output wire [7:0]  o_imem_b001,
    output wire [7:0]  o_imem_b002, output wire [7:0]  o_imem_b003,
    output wire [7:0]  o_imem_b004, output wire [7:0]  o_imem_b005,
    output wire [7:0]  o_imem_b006, output wire [7:0]  o_imem_b007,
    output wire [7:0]  o_imem_b008, output wire [7:0]  o_imem_b009,
    output wire [7:0]  o_imem_b010, output wire [7:0]  o_imem_b011,
    output wire [7:0]  o_imem_b012, output wire [7:0]  o_imem_b013,
    output wire [7:0]  o_imem_b014, output wire [7:0]  o_imem_b015,
    output wire [7:0]  o_imem_b016, output wire [7:0]  o_imem_b017,
    output wire [7:0]  o_imem_b018, output wire [7:0]  o_imem_b019,
    output wire [7:0]  o_imem_b020, output wire [7:0]  o_imem_b021,
    output wire [7:0]  o_imem_b022, output wire [7:0]  o_imem_b023,
    output wire [7:0]  o_imem_b024, output wire [7:0]  o_imem_b025,
    output wire [7:0]  o_imem_b026, output wire [7:0]  o_imem_b027,
    output wire [7:0]  o_imem_b028, output wire [7:0]  o_imem_b029,
    output wire [7:0]  o_imem_b030, output wire [7:0]  o_imem_b031,
    output wire [7:0]  o_imem_b032, output wire [7:0]  o_imem_b033,
    output wire [7:0]  o_imem_b034, output wire [7:0]  o_imem_b035,
    output wire [7:0]  o_imem_b036, output wire [7:0]  o_imem_b037,
    output wire [7:0]  o_imem_b038, output wire [7:0]  o_imem_b039,
    output wire [7:0]  o_imem_b040, output wire [7:0]  o_imem_b041,
    output wire [7:0]  o_imem_b042, output wire [7:0]  o_imem_b043,
    output wire [7:0]  o_imem_b044, output wire [7:0]  o_imem_b045,
    output wire [7:0]  o_imem_b046, output wire [7:0]  o_imem_b047,
    output wire [7:0]  o_imem_b048, output wire [7:0]  o_imem_b049,
    output wire [7:0]  o_imem_b050, output wire [7:0]  o_imem_b051,
    output wire [7:0]  o_imem_b052, output wire [7:0]  o_imem_b053,
    output wire [7:0]  o_imem_b054, output wire [7:0]  o_imem_b055,
    output wire [7:0]  o_imem_b056, output wire [7:0]  o_imem_b057,
    output wire [7:0]  o_imem_b058, output wire [7:0]  o_imem_b059,
    output wire [7:0]  o_imem_b060, output wire [7:0]  o_imem_b061,
    output wire [7:0]  o_imem_b062, output wire [7:0]  o_imem_b063,
    output wire [7:0]  o_imem_b064, output wire [7:0]  o_imem_b065,
    output wire [7:0]  o_imem_b066, output wire [7:0]  o_imem_b067,
    output wire [7:0]  o_imem_b068, output wire [7:0]  o_imem_b069,
    output wire [7:0]  o_imem_b070, output wire [7:0]  o_imem_b071,
    output wire [7:0]  o_imem_b072, output wire [7:0]  o_imem_b073,
    output wire [7:0]  o_imem_b074, output wire [7:0]  o_imem_b075,
    output wire [7:0]  o_imem_b076, output wire [7:0]  o_imem_b077,
    output wire [7:0]  o_imem_b078, output wire [7:0]  o_imem_b079,
    output wire [7:0]  o_imem_b080, output wire [7:0]  o_imem_b081,
    output wire [7:0]  o_imem_b082, output wire [7:0]  o_imem_b083,
    output wire [7:0]  o_imem_b084, output wire [7:0]  o_imem_b085,
    output wire [7:0]  o_imem_b086, output wire [7:0]  o_imem_b087,
    output wire [7:0]  o_imem_b088, output wire [7:0]  o_imem_b089,
    output wire [7:0]  o_imem_b090, output wire [7:0]  o_imem_b091,
    output wire [7:0]  o_imem_b092, output wire [7:0]  o_imem_b093,
    output wire [7:0]  o_imem_b094, output wire [7:0]  o_imem_b095,
    output wire [7:0]  o_imem_b096, output wire [7:0]  o_imem_b097,
    output wire [7:0]  o_imem_b098, output wire [7:0]  o_imem_b099,
    output wire [7:0]  o_imem_b100, output wire [7:0]  o_imem_b101,
    output wire [7:0]  o_imem_b102, output wire [7:0]  o_imem_b103,
    output wire [7:0]  o_imem_b104, output wire [7:0]  o_imem_b105,
    output wire [7:0]  o_imem_b106, output wire [7:0]  o_imem_b107,
    output wire [7:0]  o_imem_b108, output wire [7:0]  o_imem_b109,
    output wire [7:0]  o_imem_b110, output wire [7:0]  o_imem_b111,
    output wire [7:0]  o_imem_b112, output wire [7:0]  o_imem_b113,
    output wire [7:0]  o_imem_b114, output wire [7:0]  o_imem_b115,
    output wire [7:0]  o_imem_b116, output wire [7:0]  o_imem_b117,
    output wire [7:0]  o_imem_b118, output wire [7:0]  o_imem_b119,
    output wire [7:0]  o_imem_b120, output wire [7:0]  o_imem_b121,
    output wire [7:0]  o_imem_b122, output wire [7:0]  o_imem_b123,
    output wire [7:0]  o_imem_b124, output wire [7:0]  o_imem_b125,
    output wire [7:0]  o_imem_b126, output wire [7:0]  o_imem_b127,
    output wire [7:0]  o_imem_b128, output wire [7:0]  o_imem_b129,
    output wire [7:0]  o_imem_b130, output wire [7:0]  o_imem_b131,
    output wire [7:0]  o_imem_b132, output wire [7:0]  o_imem_b133,
    output wire [7:0]  o_imem_b134, output wire [7:0]  o_imem_b135,
    output wire [7:0]  o_imem_b136, output wire [7:0]  o_imem_b137,
    output wire [7:0]  o_imem_b138, output wire [7:0]  o_imem_b139,
    output wire [7:0]  o_imem_b140, output wire [7:0]  o_imem_b141,
    output wire [7:0]  o_imem_b142, output wire [7:0]  o_imem_b143,
    output wire [7:0]  o_imem_b144, output wire [7:0]  o_imem_b145,
    output wire [7:0]  o_imem_b146, output wire [7:0]  o_imem_b147,
    output wire [7:0]  o_imem_b148, output wire [7:0]  o_imem_b149,
    output wire [7:0]  o_imem_b150, output wire [7:0]  o_imem_b151,
    output wire [7:0]  o_imem_b152, output wire [7:0]  o_imem_b153,
    output wire [7:0]  o_imem_b154, output wire [7:0]  o_imem_b155,
    output wire [7:0]  o_imem_b156, output wire [7:0]  o_imem_b157,
    output wire [7:0]  o_imem_b158, output wire [7:0]  o_imem_b159,
    output wire [7:0]  o_imem_b160, output wire [7:0]  o_imem_b161,
    output wire [7:0]  o_imem_b162, output wire [7:0]  o_imem_b163,
    output wire [7:0]  o_imem_b164, output wire [7:0]  o_imem_b165,
    output wire [7:0]  o_imem_b166, output wire [7:0]  o_imem_b167,
    output wire [7:0]  o_imem_b168, output wire [7:0]  o_imem_b169,
    output wire [7:0]  o_imem_b170, output wire [7:0]  o_imem_b171,
    output wire [7:0]  o_imem_b172, output wire [7:0]  o_imem_b173,
    output wire [7:0]  o_imem_b174, output wire [7:0]  o_imem_b175,
    output wire [7:0]  o_imem_b176, output wire [7:0]  o_imem_b177,
    output wire [7:0]  o_imem_b178, output wire [7:0]  o_imem_b179,
    output wire [7:0]  o_imem_b180, output wire [7:0]  o_imem_b181,
    output wire [7:0]  o_imem_b182, output wire [7:0]  o_imem_b183,
    output wire [7:0]  o_imem_b184, output wire [7:0]  o_imem_b185,
    output wire [7:0]  o_imem_b186, output wire [7:0]  o_imem_b187,
    output wire [7:0]  o_imem_b188, output wire [7:0]  o_imem_b189,
    output wire [7:0]  o_imem_b190, output wire [7:0]  o_imem_b191,
    output wire [7:0]  o_imem_b192, output wire [7:0]  o_imem_b193,
    output wire [7:0]  o_imem_b194, output wire [7:0]  o_imem_b195,
    output wire [7:0]  o_imem_b196, output wire [7:0]  o_imem_b197,
    output wire [7:0]  o_imem_b198, output wire [7:0]  o_imem_b199,
    output wire [7:0]  o_imem_b200, output wire [7:0]  o_imem_b201,
    output wire [7:0]  o_imem_b202, output wire [7:0]  o_imem_b203,
    output wire [7:0]  o_imem_b204, output wire [7:0]  o_imem_b205,
    output wire [7:0]  o_imem_b206, output wire [7:0]  o_imem_b207,
    output wire [7:0]  o_imem_b208, output wire [7:0]  o_imem_b209,
    output wire [7:0]  o_imem_b210, output wire [7:0]  o_imem_b211,
    output wire [7:0]  o_imem_b212, output wire [7:0]  o_imem_b213,
    output wire [7:0]  o_imem_b214, output wire [7:0]  o_imem_b215,
    output wire [7:0]  o_imem_b216, output wire [7:0]  o_imem_b217,
    output wire [7:0]  o_imem_b218, output wire [7:0]  o_imem_b219,
    output wire [7:0]  o_imem_b220, output wire [7:0]  o_imem_b221,
    output wire [7:0]  o_imem_b222, output wire [7:0]  o_imem_b223,
    output wire [7:0]  o_imem_b224, output wire [7:0]  o_imem_b225,
    output wire [7:0]  o_imem_b226, output wire [7:0]  o_imem_b227,
    output wire [7:0]  o_imem_b228, output wire [7:0]  o_imem_b229,
    output wire [7:0]  o_imem_b230, output wire [7:0]  o_imem_b231,
    output wire [7:0]  o_imem_b232, output wire [7:0]  o_imem_b233,
    output wire [7:0]  o_imem_b234, output wire [7:0]  o_imem_b235,
    output wire [7:0]  o_imem_b236, output wire [7:0]  o_imem_b237,
    output wire [7:0]  o_imem_b238, output wire [7:0]  o_imem_b239,
    output wire [7:0]  o_imem_b240, output wire [7:0]  o_imem_b241,
    output wire [7:0]  o_imem_b242, output wire [7:0]  o_imem_b243,
    output wire [7:0]  o_imem_b244, output wire [7:0]  o_imem_b245,
    output wire [7:0]  o_imem_b246, output wire [7:0]  o_imem_b247,
    output wire [7:0]  o_imem_b248, output wire [7:0]  o_imem_b249,
    output wire [7:0]  o_imem_b250, output wire [7:0]  o_imem_b251,
    output wire [7:0]  o_imem_b252, output wire [7:0]  o_imem_b253,
    output wire [7:0]  o_imem_b254, output wire [7:0]  o_imem_b255,

    // --------------------------------------------------------
    // Data memory - full 512-byte read-back bus
    // --------------------------------------------------------
    output wire [7:0]  o_dmem_b000, output wire [7:0]  o_dmem_b001,
    output wire [7:0]  o_dmem_b002, output wire [7:0]  o_dmem_b003,
    output wire [7:0]  o_dmem_b004, output wire [7:0]  o_dmem_b005,
    output wire [7:0]  o_dmem_b006, output wire [7:0]  o_dmem_b007,
    output wire [7:0]  o_dmem_b008, output wire [7:0]  o_dmem_b009,
    output wire [7:0]  o_dmem_b010, output wire [7:0]  o_dmem_b011,
    output wire [7:0]  o_dmem_b012, output wire [7:0]  o_dmem_b013,
    output wire [7:0]  o_dmem_b014, output wire [7:0]  o_dmem_b015,
    output wire [7:0]  o_dmem_b016, output wire [7:0]  o_dmem_b017,
    output wire [7:0]  o_dmem_b018, output wire [7:0]  o_dmem_b019,
    output wire [7:0]  o_dmem_b020, output wire [7:0]  o_dmem_b021,
    output wire [7:0]  o_dmem_b022, output wire [7:0]  o_dmem_b023,
    output wire [7:0]  o_dmem_b024, output wire [7:0]  o_dmem_b025,
    output wire [7:0]  o_dmem_b026, output wire [7:0]  o_dmem_b027,
    output wire [7:0]  o_dmem_b028, output wire [7:0]  o_dmem_b029,
    output wire [7:0]  o_dmem_b030, output wire [7:0]  o_dmem_b031,
    output wire [7:0]  o_dmem_b032, output wire [7:0]  o_dmem_b033,
    output wire [7:0]  o_dmem_b034, output wire [7:0]  o_dmem_b035,
    output wire [7:0]  o_dmem_b036, output wire [7:0]  o_dmem_b037,
    output wire [7:0]  o_dmem_b038, output wire [7:0]  o_dmem_b039,
    output wire [7:0]  o_dmem_b040, output wire [7:0]  o_dmem_b041,
    output wire [7:0]  o_dmem_b042, output wire [7:0]  o_dmem_b043,
    output wire [7:0]  o_dmem_b044, output wire [7:0]  o_dmem_b045,
    output wire [7:0]  o_dmem_b046, output wire [7:0]  o_dmem_b047,
    output wire [7:0]  o_dmem_b048, output wire [7:0]  o_dmem_b049,
    output wire [7:0]  o_dmem_b050, output wire [7:0]  o_dmem_b051,
    output wire [7:0]  o_dmem_b052, output wire [7:0]  o_dmem_b053,
    output wire [7:0]  o_dmem_b054, output wire [7:0]  o_dmem_b055,
    output wire [7:0]  o_dmem_b056, output wire [7:0]  o_dmem_b057,
    output wire [7:0]  o_dmem_b058, output wire [7:0]  o_dmem_b059,
    output wire [7:0]  o_dmem_b060, output wire [7:0]  o_dmem_b061,
    output wire [7:0]  o_dmem_b062, output wire [7:0]  o_dmem_b063,
    output wire [7:0]  o_dmem_b064, output wire [7:0]  o_dmem_b065,
    output wire [7:0]  o_dmem_b066, output wire [7:0]  o_dmem_b067,
    output wire [7:0]  o_dmem_b068, output wire [7:0]  o_dmem_b069,
    output wire [7:0]  o_dmem_b070, output wire [7:0]  o_dmem_b071,
    output wire [7:0]  o_dmem_b072, output wire [7:0]  o_dmem_b073,
    output wire [7:0]  o_dmem_b074, output wire [7:0]  o_dmem_b075,
    output wire [7:0]  o_dmem_b076, output wire [7:0]  o_dmem_b077,
    output wire [7:0]  o_dmem_b078, output wire [7:0]  o_dmem_b079,
    output wire [7:0]  o_dmem_b080, output wire [7:0]  o_dmem_b081,
    output wire [7:0]  o_dmem_b082, output wire [7:0]  o_dmem_b083,
    output wire [7:0]  o_dmem_b084, output wire [7:0]  o_dmem_b085,
    output wire [7:0]  o_dmem_b086, output wire [7:0]  o_dmem_b087,
    output wire [7:0]  o_dmem_b088, output wire [7:0]  o_dmem_b089,
    output wire [7:0]  o_dmem_b090, output wire [7:0]  o_dmem_b091,
    output wire [7:0]  o_dmem_b092, output wire [7:0]  o_dmem_b093,
    output wire [7:0]  o_dmem_b094, output wire [7:0]  o_dmem_b095,
    output wire [7:0]  o_dmem_b096, output wire [7:0]  o_dmem_b097,
    output wire [7:0]  o_dmem_b098, output wire [7:0]  o_dmem_b099,
    output wire [7:0]  o_dmem_b100, output wire [7:0]  o_dmem_b101,
    output wire [7:0]  o_dmem_b102, output wire [7:0]  o_dmem_b103,
    output wire [7:0]  o_dmem_b104, output wire [7:0]  o_dmem_b105,
    output wire [7:0]  o_dmem_b106, output wire [7:0]  o_dmem_b107,
    output wire [7:0]  o_dmem_b108, output wire [7:0]  o_dmem_b109,
    output wire [7:0]  o_dmem_b110, output wire [7:0]  o_dmem_b111,
    output wire [7:0]  o_dmem_b112, output wire [7:0]  o_dmem_b113,
    output wire [7:0]  o_dmem_b114, output wire [7:0]  o_dmem_b115,
    output wire [7:0]  o_dmem_b116, output wire [7:0]  o_dmem_b117,
    output wire [7:0]  o_dmem_b118, output wire [7:0]  o_dmem_b119,
    output wire [7:0]  o_dmem_b120, output wire [7:0]  o_dmem_b121,
    output wire [7:0]  o_dmem_b122, output wire [7:0]  o_dmem_b123,
    output wire [7:0]  o_dmem_b124, output wire [7:0]  o_dmem_b125,
    output wire [7:0]  o_dmem_b126, output wire [7:0]  o_dmem_b127,
    output wire [7:0]  o_dmem_b128, output wire [7:0]  o_dmem_b129,
    output wire [7:0]  o_dmem_b130, output wire [7:0]  o_dmem_b131,
    output wire [7:0]  o_dmem_b132, output wire [7:0]  o_dmem_b133,
    output wire [7:0]  o_dmem_b134, output wire [7:0]  o_dmem_b135,
    output wire [7:0]  o_dmem_b136, output wire [7:0]  o_dmem_b137,
    output wire [7:0]  o_dmem_b138, output wire [7:0]  o_dmem_b139,
    output wire [7:0]  o_dmem_b140, output wire [7:0]  o_dmem_b141,
    output wire [7:0]  o_dmem_b142, output wire [7:0]  o_dmem_b143,
    output wire [7:0]  o_dmem_b144, output wire [7:0]  o_dmem_b145,
    output wire [7:0]  o_dmem_b146, output wire [7:0]  o_dmem_b147,
    output wire [7:0]  o_dmem_b148, output wire [7:0]  o_dmem_b149,
    output wire [7:0]  o_dmem_b150, output wire [7:0]  o_dmem_b151,
    output wire [7:0]  o_dmem_b152, output wire [7:0]  o_dmem_b153,
    output wire [7:0]  o_dmem_b154, output wire [7:0]  o_dmem_b155,
    output wire [7:0]  o_dmem_b156, output wire [7:0]  o_dmem_b157,
    output wire [7:0]  o_dmem_b158, output wire [7:0]  o_dmem_b159,
    output wire [7:0]  o_dmem_b160, output wire [7:0]  o_dmem_b161,
    output wire [7:0]  o_dmem_b162, output wire [7:0]  o_dmem_b163,
    output wire [7:0]  o_dmem_b164, output wire [7:0]  o_dmem_b165,
    output wire [7:0]  o_dmem_b166, output wire [7:0]  o_dmem_b167,
    output wire [7:0]  o_dmem_b168, output wire [7:0]  o_dmem_b169,
    output wire [7:0]  o_dmem_b170, output wire [7:0]  o_dmem_b171,
    output wire [7:0]  o_dmem_b172, output wire [7:0]  o_dmem_b173,
    output wire [7:0]  o_dmem_b174, output wire [7:0]  o_dmem_b175,
    output wire [7:0]  o_dmem_b176, output wire [7:0]  o_dmem_b177,
    output wire [7:0]  o_dmem_b178, output wire [7:0]  o_dmem_b179,
    output wire [7:0]  o_dmem_b180, output wire [7:0]  o_dmem_b181,
    output wire [7:0]  o_dmem_b182, output wire [7:0]  o_dmem_b183,
    output wire [7:0]  o_dmem_b184, output wire [7:0]  o_dmem_b185,
    output wire [7:0]  o_dmem_b186, output wire [7:0]  o_dmem_b187,
    output wire [7:0]  o_dmem_b188, output wire [7:0]  o_dmem_b189,
    output wire [7:0]  o_dmem_b190, output wire [7:0]  o_dmem_b191,
    output wire [7:0]  o_dmem_b192, output wire [7:0]  o_dmem_b193,
    output wire [7:0]  o_dmem_b194, output wire [7:0]  o_dmem_b195,
    output wire [7:0]  o_dmem_b196, output wire [7:0]  o_dmem_b197,
    output wire [7:0]  o_dmem_b198, output wire [7:0]  o_dmem_b199,
    output wire [7:0]  o_dmem_b200, output wire [7:0]  o_dmem_b201,
    output wire [7:0]  o_dmem_b202, output wire [7:0]  o_dmem_b203,
    output wire [7:0]  o_dmem_b204, output wire [7:0]  o_dmem_b205,
    output wire [7:0]  o_dmem_b206, output wire [7:0]  o_dmem_b207,
    output wire [7:0]  o_dmem_b208, output wire [7:0]  o_dmem_b209,
    output wire [7:0]  o_dmem_b210, output wire [7:0]  o_dmem_b211,
    output wire [7:0]  o_dmem_b212, output wire [7:0]  o_dmem_b213,
    output wire [7:0]  o_dmem_b214, output wire [7:0]  o_dmem_b215,
    output wire [7:0]  o_dmem_b216, output wire [7:0]  o_dmem_b217,
    output wire [7:0]  o_dmem_b218, output wire [7:0]  o_dmem_b219,
    output wire [7:0]  o_dmem_b220, output wire [7:0]  o_dmem_b221,
    output wire [7:0]  o_dmem_b222, output wire [7:0]  o_dmem_b223,
    output wire [7:0]  o_dmem_b224, output wire [7:0]  o_dmem_b225,
    output wire [7:0]  o_dmem_b226, output wire [7:0]  o_dmem_b227,
    output wire [7:0]  o_dmem_b228, output wire [7:0]  o_dmem_b229,
    output wire [7:0]  o_dmem_b230, output wire [7:0]  o_dmem_b231,
    output wire [7:0]  o_dmem_b232, output wire [7:0]  o_dmem_b233,
    output wire [7:0]  o_dmem_b234, output wire [7:0]  o_dmem_b235,
    output wire [7:0]  o_dmem_b236, output wire [7:0]  o_dmem_b237,
    output wire [7:0]  o_dmem_b238, output wire [7:0]  o_dmem_b239,
    output wire [7:0]  o_dmem_b240, output wire [7:0]  o_dmem_b241,
    output wire [7:0]  o_dmem_b242, output wire [7:0]  o_dmem_b243,
    output wire [7:0]  o_dmem_b244, output wire [7:0]  o_dmem_b245,
    output wire [7:0]  o_dmem_b246, output wire [7:0]  o_dmem_b247,
    output wire [7:0]  o_dmem_b248, output wire [7:0]  o_dmem_b249,
    output wire [7:0]  o_dmem_b250, output wire [7:0]  o_dmem_b251,
    output wire [7:0]  o_dmem_b252, output wire [7:0]  o_dmem_b253,
    output wire [7:0]  o_dmem_b254, output wire [7:0]  o_dmem_b255,
    output wire [7:0]  o_dmem_b256, output wire [7:0]  o_dmem_b257,
    output wire [7:0]  o_dmem_b258, output wire [7:0]  o_dmem_b259,
    output wire [7:0]  o_dmem_b260, output wire [7:0]  o_dmem_b261,
    output wire [7:0]  o_dmem_b262, output wire [7:0]  o_dmem_b263,
    output wire [7:0]  o_dmem_b264, output wire [7:0]  o_dmem_b265,
    output wire [7:0]  o_dmem_b266, output wire [7:0]  o_dmem_b267,
    output wire [7:0]  o_dmem_b268, output wire [7:0]  o_dmem_b269,
    output wire [7:0]  o_dmem_b270, output wire [7:0]  o_dmem_b271,
    output wire [7:0]  o_dmem_b272, output wire [7:0]  o_dmem_b273,
    output wire [7:0]  o_dmem_b274, output wire [7:0]  o_dmem_b275,
    output wire [7:0]  o_dmem_b276, output wire [7:0]  o_dmem_b277,
    output wire [7:0]  o_dmem_b278, output wire [7:0]  o_dmem_b279,
    output wire [7:0]  o_dmem_b280, output wire [7:0]  o_dmem_b281,
    output wire [7:0]  o_dmem_b282, output wire [7:0]  o_dmem_b283,
    output wire [7:0]  o_dmem_b284, output wire [7:0]  o_dmem_b285,
    output wire [7:0]  o_dmem_b286, output wire [7:0]  o_dmem_b287,
    output wire [7:0]  o_dmem_b288, output wire [7:0]  o_dmem_b289,
    output wire [7:0]  o_dmem_b290, output wire [7:0]  o_dmem_b291,
    output wire [7:0]  o_dmem_b292, output wire [7:0]  o_dmem_b293,
    output wire [7:0]  o_dmem_b294, output wire [7:0]  o_dmem_b295,
    output wire [7:0]  o_dmem_b296, output wire [7:0]  o_dmem_b297,
    output wire [7:0]  o_dmem_b298, output wire [7:0]  o_dmem_b299,
    output wire [7:0]  o_dmem_b300, output wire [7:0]  o_dmem_b301,
    output wire [7:0]  o_dmem_b302, output wire [7:0]  o_dmem_b303,
    output wire [7:0]  o_dmem_b304, output wire [7:0]  o_dmem_b305,
    output wire [7:0]  o_dmem_b306, output wire [7:0]  o_dmem_b307,
    output wire [7:0]  o_dmem_b308, output wire [7:0]  o_dmem_b309,
    output wire [7:0]  o_dmem_b310, output wire [7:0]  o_dmem_b311,
    output wire [7:0]  o_dmem_b312, output wire [7:0]  o_dmem_b313,
    output wire [7:0]  o_dmem_b314, output wire [7:0]  o_dmem_b315,
    output wire [7:0]  o_dmem_b316, output wire [7:0]  o_dmem_b317,
    output wire [7:0]  o_dmem_b318, output wire [7:0]  o_dmem_b319,
    output wire [7:0]  o_dmem_b320, output wire [7:0]  o_dmem_b321,
    output wire [7:0]  o_dmem_b322, output wire [7:0]  o_dmem_b323,
    output wire [7:0]  o_dmem_b324, output wire [7:0]  o_dmem_b325,
    output wire [7:0]  o_dmem_b326, output wire [7:0]  o_dmem_b327,
    output wire [7:0]  o_dmem_b328, output wire [7:0]  o_dmem_b329,
    output wire [7:0]  o_dmem_b330, output wire [7:0]  o_dmem_b331,
    output wire [7:0]  o_dmem_b332, output wire [7:0]  o_dmem_b333,
    output wire [7:0]  o_dmem_b334, output wire [7:0]  o_dmem_b335,
    output wire [7:0]  o_dmem_b336, output wire [7:0]  o_dmem_b337,
    output wire [7:0]  o_dmem_b338, output wire [7:0]  o_dmem_b339,
    output wire [7:0]  o_dmem_b340, output wire [7:0]  o_dmem_b341,
    output wire [7:0]  o_dmem_b342, output wire [7:0]  o_dmem_b343,
    output wire [7:0]  o_dmem_b344, output wire [7:0]  o_dmem_b345,
    output wire [7:0]  o_dmem_b346, output wire [7:0]  o_dmem_b347,
    output wire [7:0]  o_dmem_b348, output wire [7:0]  o_dmem_b349,
    output wire [7:0]  o_dmem_b350, output wire [7:0]  o_dmem_b351,
    output wire [7:0]  o_dmem_b352, output wire [7:0]  o_dmem_b353,
    output wire [7:0]  o_dmem_b354, output wire [7:0]  o_dmem_b355,
    output wire [7:0]  o_dmem_b356, output wire [7:0]  o_dmem_b357,
    output wire [7:0]  o_dmem_b358, output wire [7:0]  o_dmem_b359,
    output wire [7:0]  o_dmem_b360, output wire [7:0]  o_dmem_b361,
    output wire [7:0]  o_dmem_b362, output wire [7:0]  o_dmem_b363,
    output wire [7:0]  o_dmem_b364, output wire [7:0]  o_dmem_b365,
    output wire [7:0]  o_dmem_b366, output wire [7:0]  o_dmem_b367,
    output wire [7:0]  o_dmem_b368, output wire [7:0]  o_dmem_b369,
    output wire [7:0]  o_dmem_b370, output wire [7:0]  o_dmem_b371,
    output wire [7:0]  o_dmem_b372, output wire [7:0]  o_dmem_b373,
    output wire [7:0]  o_dmem_b374, output wire [7:0]  o_dmem_b375,
    output wire [7:0]  o_dmem_b376, output wire [7:0]  o_dmem_b377,
    output wire [7:0]  o_dmem_b378, output wire [7:0]  o_dmem_b379,
    output wire [7:0]  o_dmem_b380, output wire [7:0]  o_dmem_b381,
    output wire [7:0]  o_dmem_b382, output wire [7:0]  o_dmem_b383,
    output wire [7:0]  o_dmem_b384, output wire [7:0]  o_dmem_b385,
    output wire [7:0]  o_dmem_b386, output wire [7:0]  o_dmem_b387,
    output wire [7:0]  o_dmem_b388, output wire [7:0]  o_dmem_b389,
    output wire [7:0]  o_dmem_b390, output wire [7:0]  o_dmem_b391,
    output wire [7:0]  o_dmem_b392, output wire [7:0]  o_dmem_b393,
    output wire [7:0]  o_dmem_b394, output wire [7:0]  o_dmem_b395,
    output wire [7:0]  o_dmem_b396, output wire [7:0]  o_dmem_b397,
    output wire [7:0]  o_dmem_b398, output wire [7:0]  o_dmem_b399,
    output wire [7:0]  o_dmem_b400, output wire [7:0]  o_dmem_b401,
    output wire [7:0]  o_dmem_b402, output wire [7:0]  o_dmem_b403,
    output wire [7:0]  o_dmem_b404, output wire [7:0]  o_dmem_b405,
    output wire [7:0]  o_dmem_b406, output wire [7:0]  o_dmem_b407,
    output wire [7:0]  o_dmem_b408, output wire [7:0]  o_dmem_b409,
    output wire [7:0]  o_dmem_b410, output wire [7:0]  o_dmem_b411,
    output wire [7:0]  o_dmem_b412, output wire [7:0]  o_dmem_b413,
    output wire [7:0]  o_dmem_b414, output wire [7:0]  o_dmem_b415,
    output wire [7:0]  o_dmem_b416, output wire [7:0]  o_dmem_b417,
    output wire [7:0]  o_dmem_b418, output wire [7:0]  o_dmem_b419,
    output wire [7:0]  o_dmem_b420, output wire [7:0]  o_dmem_b421,
    output wire [7:0]  o_dmem_b422, output wire [7:0]  o_dmem_b423,
    output wire [7:0]  o_dmem_b424, output wire [7:0]  o_dmem_b425,
    output wire [7:0]  o_dmem_b426, output wire [7:0]  o_dmem_b427,
    output wire [7:0]  o_dmem_b428, output wire [7:0]  o_dmem_b429,
    output wire [7:0]  o_dmem_b430, output wire [7:0]  o_dmem_b431,
    output wire [7:0]  o_dmem_b432, output wire [7:0]  o_dmem_b433,
    output wire [7:0]  o_dmem_b434, output wire [7:0]  o_dmem_b435,
    output wire [7:0]  o_dmem_b436, output wire [7:0]  o_dmem_b437,
    output wire [7:0]  o_dmem_b438, output wire [7:0]  o_dmem_b439,
    output wire [7:0]  o_dmem_b440, output wire [7:0]  o_dmem_b441,
    output wire [7:0]  o_dmem_b442, output wire [7:0]  o_dmem_b443,
    output wire [7:0]  o_dmem_b444, output wire [7:0]  o_dmem_b445,
    output wire [7:0]  o_dmem_b446, output wire [7:0]  o_dmem_b447,
    output wire [7:0]  o_dmem_b448, output wire [7:0]  o_dmem_b449,
    output wire [7:0]  o_dmem_b450, output wire [7:0]  o_dmem_b451,
    output wire [7:0]  o_dmem_b452, output wire [7:0]  o_dmem_b453,
    output wire [7:0]  o_dmem_b454, output wire [7:0]  o_dmem_b455,
    output wire [7:0]  o_dmem_b456, output wire [7:0]  o_dmem_b457,
    output wire [7:0]  o_dmem_b458, output wire [7:0]  o_dmem_b459,
    output wire [7:0]  o_dmem_b460, output wire [7:0]  o_dmem_b461,
    output wire [7:0]  o_dmem_b462, output wire [7:0]  o_dmem_b463,
    output wire [7:0]  o_dmem_b464, output wire [7:0]  o_dmem_b465,
    output wire [7:0]  o_dmem_b466, output wire [7:0]  o_dmem_b467,
    output wire [7:0]  o_dmem_b468, output wire [7:0]  o_dmem_b469,
    output wire [7:0]  o_dmem_b470, output wire [7:0]  o_dmem_b471,
    output wire [7:0]  o_dmem_b472, output wire [7:0]  o_dmem_b473,
    output wire [7:0]  o_dmem_b474, output wire [7:0]  o_dmem_b475,
    output wire [7:0]  o_dmem_b476, output wire [7:0]  o_dmem_b477,
    output wire [7:0]  o_dmem_b478, output wire [7:0]  o_dmem_b479,
    output wire [7:0]  o_dmem_b480, output wire [7:0]  o_dmem_b481,
    output wire [7:0]  o_dmem_b482, output wire [7:0]  o_dmem_b483,
    output wire [7:0]  o_dmem_b484, output wire [7:0]  o_dmem_b485,
    output wire [7:0]  o_dmem_b486, output wire [7:0]  o_dmem_b487,
    output wire [7:0]  o_dmem_b488, output wire [7:0]  o_dmem_b489,
    output wire [7:0]  o_dmem_b490, output wire [7:0]  o_dmem_b491,
    output wire [7:0]  o_dmem_b492, output wire [7:0]  o_dmem_b493,
    output wire [7:0]  o_dmem_b494, output wire [7:0]  o_dmem_b495,
    output wire [7:0]  o_dmem_b496, output wire [7:0]  o_dmem_b497,
    output wire [7:0]  o_dmem_b498, output wire [7:0]  o_dmem_b499,
    output wire [7:0]  o_dmem_b500, output wire [7:0]  o_dmem_b501,
    output wire [7:0]  o_dmem_b502, output wire [7:0]  o_dmem_b503,
    output wire [7:0]  o_dmem_b504, output wire [7:0]  o_dmem_b505,
    output wire [7:0]  o_dmem_b506, output wire [7:0]  o_dmem_b507,
    output wire [7:0]  o_dmem_b508, output wire [7:0]  o_dmem_b509,
    output wire [7:0]  o_dmem_b510, output wire [7:0]  o_dmem_b511,

    // --------------------------------------------------------
    // ID/EX pipeline register outputs
    // --------------------------------------------------------
    output wire [31:0] o_id_ex_NPC,
    output wire [31:0] o_id_ex_A,
    output wire [31:0] o_id_ex_B,
    output wire [31:0] o_id_ex_Imm,
    output wire [4:0]  o_id_ex_RS,
    output wire [4:0]  o_id_ex_RT,
    output wire [4:0]  o_id_ex_RD,
    output wire        o_id_ex_RegDst,
    output wire        o_id_ex_ALUSrc,
    output wire [3:0]  o_id_ex_ALUOp,
    output wire        o_id_ex_BranchEq,
    output wire        o_id_ex_BranchNe,
    output wire        o_id_ex_MemRead,
    output wire        o_id_ex_MemWrite,
    output wire        o_id_ex_RegWrite,
    output wire        o_id_ex_MemToReg,

    // --------------------------------------------------------
    // EX stage
    // --------------------------------------------------------
    output wire [1:0]  o_forwardA,
    output wire [1:0]  o_forwardB,
    output wire [31:0] o_forwardMuxA_out,
    output wire [31:0] o_forwardMuxB_out,
    output wire [4:0]  o_ex_regDest,
    output wire [31:0] o_ex_aluB,
    output wire [3:0]  o_ex_aluOp,
    output wire [31:0] o_ex_aluResult,
    output wire        o_ex_zero,
    output wire [31:0] o_ex_shiftedImm,
    output wire [31:0] o_ex_branchTarget,

    // --------------------------------------------------------
    // EX/MEM pipeline register outputs
    // --------------------------------------------------------
    output wire [31:0] o_ex_mem_BranchTarget,
    output wire        o_ex_mem_Zero,
    output wire [31:0] o_ex_mem_AluOut,
    output wire [31:0] o_ex_mem_B,
    output wire [4:0]  o_ex_mem_RD,
    output wire        o_ex_mem_BranchEq,
    output wire        o_ex_mem_BranchNe,
    output wire        o_ex_mem_MemRead,
    output wire        o_ex_mem_MemWrite,
    output wire        o_ex_mem_RegWrite,
    output wire        o_ex_mem_MemToReg,

    // --------------------------------------------------------
    // MEM stage
    // --------------------------------------------------------
    output wire        o_mem_PCSrc,
    output wire [31:0] o_mem_readData,

    // --------------------------------------------------------
    // MEM/WB pipeline register outputs
    // --------------------------------------------------------
    output wire [31:0] o_mem_wb_LMD,
    output wire [31:0] o_mem_wb_AluOut,
    output wire [4:0]  o_mem_wb_RD,
    output wire        o_mem_wb_RegWrite,
    output wire        o_mem_wb_MemToReg,

    // --------------------------------------------------------
    // WB stage
    // --------------------------------------------------------
    output wire [31:0] o_wb_writeData,
    output wire        o_wb_regWrite,
    output wire [4:0]  o_wb_regDest
);

    // ============================================================
    // Instantiate the pipeline
    // ============================================================
    pipeline PIPELINE_INST (
        .clock   (clock),
        .reset (reset)
    );

    // ============================================================
    // Hierarchical signal taps
    // All internal wires are referenced directly through the
    // instance path so this parent drives output ports from them.
    // ============================================================

    // -- IF --
    assign o_pc_out         = PIPELINE_INST.pc_out;
    assign o_pc_plus4       = PIPELINE_INST.pc_plus4;
    assign o_pc_next        = PIPELINE_INST.pc_next;
    assign o_if_instruction = PIPELINE_INST.if_instruction;

    // -- IF/ID --
    assign o_if_id_NPC = PIPELINE_INST.if_id_NPC;
    assign o_if_id_IR  = PIPELINE_INST.if_id_IR;

    // -- ID fields --
    assign o_id_opcode = PIPELINE_INST.id_opcode;
    assign o_id_RS     = PIPELINE_INST.id_RS;
    assign o_id_RT     = PIPELINE_INST.id_RT;
    assign o_id_RD     = PIPELINE_INST.id_RD;
    assign o_id_funct  = PIPELINE_INST.id_funct;
    assign o_id_imm16  = PIPELINE_INST.id_imm16;

    // -- ID control --
    assign o_id_regDst   = PIPELINE_INST.id_regDst;
    assign o_id_aluSrc   = PIPELINE_INST.id_aluSrc;
    assign o_id_memToReg = PIPELINE_INST.id_memToReg;
    assign o_id_regWrite = PIPELINE_INST.id_regWrite;
    assign o_id_memRead  = PIPELINE_INST.id_memRead;
    assign o_id_memWrite = PIPELINE_INST.id_memWrite;
    assign o_id_branchEq = PIPELINE_INST.id_branchEq;
    assign o_id_branchNe = PIPELINE_INST.id_branchNe;
    assign o_id_jump     = PIPELINE_INST.id_jump;
    assign o_id_aluOp    = PIPELINE_INST.id_aluOp;

    // -- ID immediate / regfile --
    assign o_id_signImm   = PIPELINE_INST.id_signImm;
    assign o_id_zeroImm   = PIPELINE_INST.id_zeroImm;
    assign o_id_immSelect = PIPELINE_INST.id_immSelect;
    assign o_id_imm       = PIPELINE_INST.id_imm;
    assign o_id_rd1       = PIPELINE_INST.id_rd1;
    assign o_id_rd2       = PIPELINE_INST.id_rd2;

    // -- Register file full read-back --
    assign o_reg00 = PIPELINE_INST.REGFILE.regBank[0];
    assign o_reg01 = PIPELINE_INST.REGFILE.regBank[1];
    assign o_reg02 = PIPELINE_INST.REGFILE.regBank[2];
    assign o_reg03 = PIPELINE_INST.REGFILE.regBank[3];
    assign o_reg04 = PIPELINE_INST.REGFILE.regBank[4];
    assign o_reg05 = PIPELINE_INST.REGFILE.regBank[5];
    assign o_reg06 = PIPELINE_INST.REGFILE.regBank[6];
    assign o_reg07 = PIPELINE_INST.REGFILE.regBank[7];
    assign o_reg08 = PIPELINE_INST.REGFILE.regBank[8];
    assign o_reg09 = PIPELINE_INST.REGFILE.regBank[9];
    assign o_reg10 = PIPELINE_INST.REGFILE.regBank[10];
    assign o_reg11 = PIPELINE_INST.REGFILE.regBank[11];
    assign o_reg12 = PIPELINE_INST.REGFILE.regBank[12];
    assign o_reg13 = PIPELINE_INST.REGFILE.regBank[13];
    assign o_reg14 = PIPELINE_INST.REGFILE.regBank[14];
    assign o_reg15 = PIPELINE_INST.REGFILE.regBank[15];
    assign o_reg16 = PIPELINE_INST.REGFILE.regBank[16];
    assign o_reg17 = PIPELINE_INST.REGFILE.regBank[17];
    assign o_reg18 = PIPELINE_INST.REGFILE.regBank[18];
    assign o_reg19 = PIPELINE_INST.REGFILE.regBank[19];
    assign o_reg20 = PIPELINE_INST.REGFILE.regBank[20];
    assign o_reg21 = PIPELINE_INST.REGFILE.regBank[21];
    assign o_reg22 = PIPELINE_INST.REGFILE.regBank[22];
    assign o_reg23 = PIPELINE_INST.REGFILE.regBank[23];
    assign o_reg24 = PIPELINE_INST.REGFILE.regBank[24];
    assign o_reg25 = PIPELINE_INST.REGFILE.regBank[25];
    assign o_reg26 = PIPELINE_INST.REGFILE.regBank[26];
    assign o_reg27 = PIPELINE_INST.REGFILE.regBank[27];
    assign o_reg28 = PIPELINE_INST.REGFILE.regBank[28];
    assign o_reg29 = PIPELINE_INST.REGFILE.regBank[29];
    assign o_reg30 = PIPELINE_INST.REGFILE.regBank[30];
    assign o_reg31 = PIPELINE_INST.REGFILE.regBank[31];

    // -- Instruction memory full byte read-back (256 bytes) --
    assign o_imem_b000 = PIPELINE_INST.IMEM.mem[0];
    assign o_imem_b001 = PIPELINE_INST.IMEM.mem[1];
    assign o_imem_b002 = PIPELINE_INST.IMEM.mem[2];
    assign o_imem_b003 = PIPELINE_INST.IMEM.mem[3];
    assign o_imem_b004 = PIPELINE_INST.IMEM.mem[4];
    assign o_imem_b005 = PIPELINE_INST.IMEM.mem[5];
    assign o_imem_b006 = PIPELINE_INST.IMEM.mem[6];
    assign o_imem_b007 = PIPELINE_INST.IMEM.mem[7];
    assign o_imem_b008 = PIPELINE_INST.IMEM.mem[8];
    assign o_imem_b009 = PIPELINE_INST.IMEM.mem[9];
    assign o_imem_b010 = PIPELINE_INST.IMEM.mem[10];
    assign o_imem_b011 = PIPELINE_INST.IMEM.mem[11];
    assign o_imem_b012 = PIPELINE_INST.IMEM.mem[12];
    assign o_imem_b013 = PIPELINE_INST.IMEM.mem[13];
    assign o_imem_b014 = PIPELINE_INST.IMEM.mem[14];
    assign o_imem_b015 = PIPELINE_INST.IMEM.mem[15];
    assign o_imem_b016 = PIPELINE_INST.IMEM.mem[16];
    assign o_imem_b017 = PIPELINE_INST.IMEM.mem[17];
    assign o_imem_b018 = PIPELINE_INST.IMEM.mem[18];
    assign o_imem_b019 = PIPELINE_INST.IMEM.mem[19];
    assign o_imem_b020 = PIPELINE_INST.IMEM.mem[20];
    assign o_imem_b021 = PIPELINE_INST.IMEM.mem[21];
    assign o_imem_b022 = PIPELINE_INST.IMEM.mem[22];
    assign o_imem_b023 = PIPELINE_INST.IMEM.mem[23];
    assign o_imem_b024 = PIPELINE_INST.IMEM.mem[24];
    assign o_imem_b025 = PIPELINE_INST.IMEM.mem[25];
    assign o_imem_b026 = PIPELINE_INST.IMEM.mem[26];
    assign o_imem_b027 = PIPELINE_INST.IMEM.mem[27];
    assign o_imem_b028 = PIPELINE_INST.IMEM.mem[28];
    assign o_imem_b029 = PIPELINE_INST.IMEM.mem[29];
    assign o_imem_b030 = PIPELINE_INST.IMEM.mem[30];
    assign o_imem_b031 = PIPELINE_INST.IMEM.mem[31];
    assign o_imem_b032 = PIPELINE_INST.IMEM.mem[32];
    assign o_imem_b033 = PIPELINE_INST.IMEM.mem[33];
    assign o_imem_b034 = PIPELINE_INST.IMEM.mem[34];
    assign o_imem_b035 = PIPELINE_INST.IMEM.mem[35];
    assign o_imem_b036 = PIPELINE_INST.IMEM.mem[36];
    assign o_imem_b037 = PIPELINE_INST.IMEM.mem[37];
    assign o_imem_b038 = PIPELINE_INST.IMEM.mem[38];
    assign o_imem_b039 = PIPELINE_INST.IMEM.mem[39];
    assign o_imem_b040 = PIPELINE_INST.IMEM.mem[40];
    assign o_imem_b041 = PIPELINE_INST.IMEM.mem[41];
    assign o_imem_b042 = PIPELINE_INST.IMEM.mem[42];
    assign o_imem_b043 = PIPELINE_INST.IMEM.mem[43];
    assign o_imem_b044 = PIPELINE_INST.IMEM.mem[44];
    assign o_imem_b045 = PIPELINE_INST.IMEM.mem[45];
    assign o_imem_b046 = PIPELINE_INST.IMEM.mem[46];
    assign o_imem_b047 = PIPELINE_INST.IMEM.mem[47];
    assign o_imem_b048 = PIPELINE_INST.IMEM.mem[48];
    assign o_imem_b049 = PIPELINE_INST.IMEM.mem[49];
    assign o_imem_b050 = PIPELINE_INST.IMEM.mem[50];
    assign o_imem_b051 = PIPELINE_INST.IMEM.mem[51];
    assign o_imem_b052 = PIPELINE_INST.IMEM.mem[52];
    assign o_imem_b053 = PIPELINE_INST.IMEM.mem[53];
    assign o_imem_b054 = PIPELINE_INST.IMEM.mem[54];
    assign o_imem_b055 = PIPELINE_INST.IMEM.mem[55];
    assign o_imem_b056 = PIPELINE_INST.IMEM.mem[56];
    assign o_imem_b057 = PIPELINE_INST.IMEM.mem[57];
    assign o_imem_b058 = PIPELINE_INST.IMEM.mem[58];
    assign o_imem_b059 = PIPELINE_INST.IMEM.mem[59];
    assign o_imem_b060 = PIPELINE_INST.IMEM.mem[60];
    assign o_imem_b061 = PIPELINE_INST.IMEM.mem[61];
    assign o_imem_b062 = PIPELINE_INST.IMEM.mem[62];
    assign o_imem_b063 = PIPELINE_INST.IMEM.mem[63];
    assign o_imem_b064 = PIPELINE_INST.IMEM.mem[64];
    assign o_imem_b065 = PIPELINE_INST.IMEM.mem[65];
    assign o_imem_b066 = PIPELINE_INST.IMEM.mem[66];
    assign o_imem_b067 = PIPELINE_INST.IMEM.mem[67];
    assign o_imem_b068 = PIPELINE_INST.IMEM.mem[68];
    assign o_imem_b069 = PIPELINE_INST.IMEM.mem[69];
    assign o_imem_b070 = PIPELINE_INST.IMEM.mem[70];
    assign o_imem_b071 = PIPELINE_INST.IMEM.mem[71];
    assign o_imem_b072 = PIPELINE_INST.IMEM.mem[72];
    assign o_imem_b073 = PIPELINE_INST.IMEM.mem[73];
    assign o_imem_b074 = PIPELINE_INST.IMEM.mem[74];
    assign o_imem_b075 = PIPELINE_INST.IMEM.mem[75];
    assign o_imem_b076 = PIPELINE_INST.IMEM.mem[76];
    assign o_imem_b077 = PIPELINE_INST.IMEM.mem[77];
    assign o_imem_b078 = PIPELINE_INST.IMEM.mem[78];
    assign o_imem_b079 = PIPELINE_INST.IMEM.mem[79];
    assign o_imem_b080 = PIPELINE_INST.IMEM.mem[80];
    assign o_imem_b081 = PIPELINE_INST.IMEM.mem[81];
    assign o_imem_b082 = PIPELINE_INST.IMEM.mem[82];
    assign o_imem_b083 = PIPELINE_INST.IMEM.mem[83];
    assign o_imem_b084 = PIPELINE_INST.IMEM.mem[84];
    assign o_imem_b085 = PIPELINE_INST.IMEM.mem[85];
    assign o_imem_b086 = PIPELINE_INST.IMEM.mem[86];
    assign o_imem_b087 = PIPELINE_INST.IMEM.mem[87];
    assign o_imem_b088 = PIPELINE_INST.IMEM.mem[88];
    assign o_imem_b089 = PIPELINE_INST.IMEM.mem[89];
    assign o_imem_b090 = PIPELINE_INST.IMEM.mem[90];
    assign o_imem_b091 = PIPELINE_INST.IMEM.mem[91];
    assign o_imem_b092 = PIPELINE_INST.IMEM.mem[92];
    assign o_imem_b093 = PIPELINE_INST.IMEM.mem[93];
    assign o_imem_b094 = PIPELINE_INST.IMEM.mem[94];
    assign o_imem_b095 = PIPELINE_INST.IMEM.mem[95];
    assign o_imem_b096 = PIPELINE_INST.IMEM.mem[96];
    assign o_imem_b097 = PIPELINE_INST.IMEM.mem[97];
    assign o_imem_b098 = PIPELINE_INST.IMEM.mem[98];
    assign o_imem_b099 = PIPELINE_INST.IMEM.mem[99];
    assign o_imem_b100 = PIPELINE_INST.IMEM.mem[100];
    assign o_imem_b101 = PIPELINE_INST.IMEM.mem[101];
    assign o_imem_b102 = PIPELINE_INST.IMEM.mem[102];
    assign o_imem_b103 = PIPELINE_INST.IMEM.mem[103];
    assign o_imem_b104 = PIPELINE_INST.IMEM.mem[104];
    assign o_imem_b105 = PIPELINE_INST.IMEM.mem[105];
    assign o_imem_b106 = PIPELINE_INST.IMEM.mem[106];
    assign o_imem_b107 = PIPELINE_INST.IMEM.mem[107];
    assign o_imem_b108 = PIPELINE_INST.IMEM.mem[108];
    assign o_imem_b109 = PIPELINE_INST.IMEM.mem[109];
    assign o_imem_b110 = PIPELINE_INST.IMEM.mem[110];
    assign o_imem_b111 = PIPELINE_INST.IMEM.mem[111];
    assign o_imem_b112 = PIPELINE_INST.IMEM.mem[112];
    assign o_imem_b113 = PIPELINE_INST.IMEM.mem[113];
    assign o_imem_b114 = PIPELINE_INST.IMEM.mem[114];
    assign o_imem_b115 = PIPELINE_INST.IMEM.mem[115];
    assign o_imem_b116 = PIPELINE_INST.IMEM.mem[116];
    assign o_imem_b117 = PIPELINE_INST.IMEM.mem[117];
    assign o_imem_b118 = PIPELINE_INST.IMEM.mem[118];
    assign o_imem_b119 = PIPELINE_INST.IMEM.mem[119];
    assign o_imem_b120 = PIPELINE_INST.IMEM.mem[120];
    assign o_imem_b121 = PIPELINE_INST.IMEM.mem[121];
    assign o_imem_b122 = PIPELINE_INST.IMEM.mem[122];
    assign o_imem_b123 = PIPELINE_INST.IMEM.mem[123];
    assign o_imem_b124 = PIPELINE_INST.IMEM.mem[124];
    assign o_imem_b125 = PIPELINE_INST.IMEM.mem[125];
    assign o_imem_b126 = PIPELINE_INST.IMEM.mem[126];
    assign o_imem_b127 = PIPELINE_INST.IMEM.mem[127];
    assign o_imem_b128 = PIPELINE_INST.IMEM.mem[128];
    assign o_imem_b129 = PIPELINE_INST.IMEM.mem[129];
    assign o_imem_b130 = PIPELINE_INST.IMEM.mem[130];
    assign o_imem_b131 = PIPELINE_INST.IMEM.mem[131];
    assign o_imem_b132 = PIPELINE_INST.IMEM.mem[132];
    assign o_imem_b133 = PIPELINE_INST.IMEM.mem[133];
    assign o_imem_b134 = PIPELINE_INST.IMEM.mem[134];
    assign o_imem_b135 = PIPELINE_INST.IMEM.mem[135];
    assign o_imem_b136 = PIPELINE_INST.IMEM.mem[136];
    assign o_imem_b137 = PIPELINE_INST.IMEM.mem[137];
    assign o_imem_b138 = PIPELINE_INST.IMEM.mem[138];
    assign o_imem_b139 = PIPELINE_INST.IMEM.mem[139];
    assign o_imem_b140 = PIPELINE_INST.IMEM.mem[140];
    assign o_imem_b141 = PIPELINE_INST.IMEM.mem[141];
    assign o_imem_b142 = PIPELINE_INST.IMEM.mem[142];
    assign o_imem_b143 = PIPELINE_INST.IMEM.mem[143];
    assign o_imem_b144 = PIPELINE_INST.IMEM.mem[144];
    assign o_imem_b145 = PIPELINE_INST.IMEM.mem[145];
    assign o_imem_b146 = PIPELINE_INST.IMEM.mem[146];
    assign o_imem_b147 = PIPELINE_INST.IMEM.mem[147];
    assign o_imem_b148 = PIPELINE_INST.IMEM.mem[148];
    assign o_imem_b149 = PIPELINE_INST.IMEM.mem[149];
    assign o_imem_b150 = PIPELINE_INST.IMEM.mem[150];
    assign o_imem_b151 = PIPELINE_INST.IMEM.mem[151];
    assign o_imem_b152 = PIPELINE_INST.IMEM.mem[152];
    assign o_imem_b153 = PIPELINE_INST.IMEM.mem[153];
    assign o_imem_b154 = PIPELINE_INST.IMEM.mem[154];
    assign o_imem_b155 = PIPELINE_INST.IMEM.mem[155];
    assign o_imem_b156 = PIPELINE_INST.IMEM.mem[156];
    assign o_imem_b157 = PIPELINE_INST.IMEM.mem[157];
    assign o_imem_b158 = PIPELINE_INST.IMEM.mem[158];
    assign o_imem_b159 = PIPELINE_INST.IMEM.mem[159];
    assign o_imem_b160 = PIPELINE_INST.IMEM.mem[160];
    assign o_imem_b161 = PIPELINE_INST.IMEM.mem[161];
    assign o_imem_b162 = PIPELINE_INST.IMEM.mem[162];
    assign o_imem_b163 = PIPELINE_INST.IMEM.mem[163];
    assign o_imem_b164 = PIPELINE_INST.IMEM.mem[164];
    assign o_imem_b165 = PIPELINE_INST.IMEM.mem[165];
    assign o_imem_b166 = PIPELINE_INST.IMEM.mem[166];
    assign o_imem_b167 = PIPELINE_INST.IMEM.mem[167];
    assign o_imem_b168 = PIPELINE_INST.IMEM.mem[168];
    assign o_imem_b169 = PIPELINE_INST.IMEM.mem[169];
    assign o_imem_b170 = PIPELINE_INST.IMEM.mem[170];
    assign o_imem_b171 = PIPELINE_INST.IMEM.mem[171];
    assign o_imem_b172 = PIPELINE_INST.IMEM.mem[172];
    assign o_imem_b173 = PIPELINE_INST.IMEM.mem[173];
    assign o_imem_b174 = PIPELINE_INST.IMEM.mem[174];
    assign o_imem_b175 = PIPELINE_INST.IMEM.mem[175];
    assign o_imem_b176 = PIPELINE_INST.IMEM.mem[176];
    assign o_imem_b177 = PIPELINE_INST.IMEM.mem[177];
    assign o_imem_b178 = PIPELINE_INST.IMEM.mem[178];
    assign o_imem_b179 = PIPELINE_INST.IMEM.mem[179];
    assign o_imem_b180 = PIPELINE_INST.IMEM.mem[180];
    assign o_imem_b181 = PIPELINE_INST.IMEM.mem[181];
    assign o_imem_b182 = PIPELINE_INST.IMEM.mem[182];
    assign o_imem_b183 = PIPELINE_INST.IMEM.mem[183];
    assign o_imem_b184 = PIPELINE_INST.IMEM.mem[184];
    assign o_imem_b185 = PIPELINE_INST.IMEM.mem[185];
    assign o_imem_b186 = PIPELINE_INST.IMEM.mem[186];
    assign o_imem_b187 = PIPELINE_INST.IMEM.mem[187];
    assign o_imem_b188 = PIPELINE_INST.IMEM.mem[188];
    assign o_imem_b189 = PIPELINE_INST.IMEM.mem[189];
    assign o_imem_b190 = PIPELINE_INST.IMEM.mem[190];
    assign o_imem_b191 = PIPELINE_INST.IMEM.mem[191];
    assign o_imem_b192 = PIPELINE_INST.IMEM.mem[192];
    assign o_imem_b193 = PIPELINE_INST.IMEM.mem[193];
    assign o_imem_b194 = PIPELINE_INST.IMEM.mem[194];
    assign o_imem_b195 = PIPELINE_INST.IMEM.mem[195];
    assign o_imem_b196 = PIPELINE_INST.IMEM.mem[196];
    assign o_imem_b197 = PIPELINE_INST.IMEM.mem[197];
    assign o_imem_b198 = PIPELINE_INST.IMEM.mem[198];
    assign o_imem_b199 = PIPELINE_INST.IMEM.mem[199];
    assign o_imem_b200 = PIPELINE_INST.IMEM.mem[200];
    assign o_imem_b201 = PIPELINE_INST.IMEM.mem[201];
    assign o_imem_b202 = PIPELINE_INST.IMEM.mem[202];
    assign o_imem_b203 = PIPELINE_INST.IMEM.mem[203];
    assign o_imem_b204 = PIPELINE_INST.IMEM.mem[204];
    assign o_imem_b205 = PIPELINE_INST.IMEM.mem[205];
    assign o_imem_b206 = PIPELINE_INST.IMEM.mem[206];
    assign o_imem_b207 = PIPELINE_INST.IMEM.mem[207];
    assign o_imem_b208 = PIPELINE_INST.IMEM.mem[208];
    assign o_imem_b209 = PIPELINE_INST.IMEM.mem[209];
    assign o_imem_b210 = PIPELINE_INST.IMEM.mem[210];
    assign o_imem_b211 = PIPELINE_INST.IMEM.mem[211];
    assign o_imem_b212 = PIPELINE_INST.IMEM.mem[212];
    assign o_imem_b213 = PIPELINE_INST.IMEM.mem[213];
    assign o_imem_b214 = PIPELINE_INST.IMEM.mem[214];
    assign o_imem_b215 = PIPELINE_INST.IMEM.mem[215];
    assign o_imem_b216 = PIPELINE_INST.IMEM.mem[216];
    assign o_imem_b217 = PIPELINE_INST.IMEM.mem[217];
    assign o_imem_b218 = PIPELINE_INST.IMEM.mem[218];
    assign o_imem_b219 = PIPELINE_INST.IMEM.mem[219];
    assign o_imem_b220 = PIPELINE_INST.IMEM.mem[220];
    assign o_imem_b221 = PIPELINE_INST.IMEM.mem[221];
    assign o_imem_b222 = PIPELINE_INST.IMEM.mem[222];
    assign o_imem_b223 = PIPELINE_INST.IMEM.mem[223];
    assign o_imem_b224 = PIPELINE_INST.IMEM.mem[224];
    assign o_imem_b225 = PIPELINE_INST.IMEM.mem[225];
    assign o_imem_b226 = PIPELINE_INST.IMEM.mem[226];
    assign o_imem_b227 = PIPELINE_INST.IMEM.mem[227];
    assign o_imem_b228 = PIPELINE_INST.IMEM.mem[228];
    assign o_imem_b229 = PIPELINE_INST.IMEM.mem[229];
    assign o_imem_b230 = PIPELINE_INST.IMEM.mem[230];
    assign o_imem_b231 = PIPELINE_INST.IMEM.mem[231];
    assign o_imem_b232 = PIPELINE_INST.IMEM.mem[232];
    assign o_imem_b233 = PIPELINE_INST.IMEM.mem[233];
    assign o_imem_b234 = PIPELINE_INST.IMEM.mem[234];
    assign o_imem_b235 = PIPELINE_INST.IMEM.mem[235];
    assign o_imem_b236 = PIPELINE_INST.IMEM.mem[236];
    assign o_imem_b237 = PIPELINE_INST.IMEM.mem[237];
    assign o_imem_b238 = PIPELINE_INST.IMEM.mem[238];
    assign o_imem_b239 = PIPELINE_INST.IMEM.mem[239];
    assign o_imem_b240 = PIPELINE_INST.IMEM.mem[240];
    assign o_imem_b241 = PIPELINE_INST.IMEM.mem[241];
    assign o_imem_b242 = PIPELINE_INST.IMEM.mem[242];
    assign o_imem_b243 = PIPELINE_INST.IMEM.mem[243];
    assign o_imem_b244 = PIPELINE_INST.IMEM.mem[244];
    assign o_imem_b245 = PIPELINE_INST.IMEM.mem[245];
    assign o_imem_b246 = PIPELINE_INST.IMEM.mem[246];
    assign o_imem_b247 = PIPELINE_INST.IMEM.mem[247];
    assign o_imem_b248 = PIPELINE_INST.IMEM.mem[248];
    assign o_imem_b249 = PIPELINE_INST.IMEM.mem[249];
    assign o_imem_b250 = PIPELINE_INST.IMEM.mem[250];
    assign o_imem_b251 = PIPELINE_INST.IMEM.mem[251];
    assign o_imem_b252 = PIPELINE_INST.IMEM.mem[252];
    assign o_imem_b253 = PIPELINE_INST.IMEM.mem[253];
    assign o_imem_b254 = PIPELINE_INST.IMEM.mem[254];
    assign o_imem_b255 = PIPELINE_INST.IMEM.mem[255];

    // -- Data memory full byte read-back (512 bytes) --
    assign o_dmem_b000 = PIPELINE_INST.DMEM.mem[0];
    assign o_dmem_b001 = PIPELINE_INST.DMEM.mem[1];
    assign o_dmem_b002 = PIPELINE_INST.DMEM.mem[2];
    assign o_dmem_b003 = PIPELINE_INST.DMEM.mem[3];
    assign o_dmem_b004 = PIPELINE_INST.DMEM.mem[4];
    assign o_dmem_b005 = PIPELINE_INST.DMEM.mem[5];
    assign o_dmem_b006 = PIPELINE_INST.DMEM.mem[6];
    assign o_dmem_b007 = PIPELINE_INST.DMEM.mem[7];
    assign o_dmem_b008 = PIPELINE_INST.DMEM.mem[8];
    assign o_dmem_b009 = PIPELINE_INST.DMEM.mem[9];
    assign o_dmem_b010 = PIPELINE_INST.DMEM.mem[10];
    assign o_dmem_b011 = PIPELINE_INST.DMEM.mem[11];
    assign o_dmem_b012 = PIPELINE_INST.DMEM.mem[12];
    assign o_dmem_b013 = PIPELINE_INST.DMEM.mem[13];
    assign o_dmem_b014 = PIPELINE_INST.DMEM.mem[14];
    assign o_dmem_b015 = PIPELINE_INST.DMEM.mem[15];
    assign o_dmem_b016 = PIPELINE_INST.DMEM.mem[16];
    assign o_dmem_b017 = PIPELINE_INST.DMEM.mem[17];
    assign o_dmem_b018 = PIPELINE_INST.DMEM.mem[18];
    assign o_dmem_b019 = PIPELINE_INST.DMEM.mem[19];
    assign o_dmem_b020 = PIPELINE_INST.DMEM.mem[20];
    assign o_dmem_b021 = PIPELINE_INST.DMEM.mem[21];
    assign o_dmem_b022 = PIPELINE_INST.DMEM.mem[22];
    assign o_dmem_b023 = PIPELINE_INST.DMEM.mem[23];
    assign o_dmem_b024 = PIPELINE_INST.DMEM.mem[24];
    assign o_dmem_b025 = PIPELINE_INST.DMEM.mem[25];
    assign o_dmem_b026 = PIPELINE_INST.DMEM.mem[26];
    assign o_dmem_b027 = PIPELINE_INST.DMEM.mem[27];
    assign o_dmem_b028 = PIPELINE_INST.DMEM.mem[28];
    assign o_dmem_b029 = PIPELINE_INST.DMEM.mem[29];
    assign o_dmem_b030 = PIPELINE_INST.DMEM.mem[30];
    assign o_dmem_b031 = PIPELINE_INST.DMEM.mem[31];
    assign o_dmem_b032 = PIPELINE_INST.DMEM.mem[32];
    assign o_dmem_b033 = PIPELINE_INST.DMEM.mem[33];
    assign o_dmem_b034 = PIPELINE_INST.DMEM.mem[34];
    assign o_dmem_b035 = PIPELINE_INST.DMEM.mem[35];
    assign o_dmem_b036 = PIPELINE_INST.DMEM.mem[36];
    assign o_dmem_b037 = PIPELINE_INST.DMEM.mem[37];
    assign o_dmem_b038 = PIPELINE_INST.DMEM.mem[38];
    assign o_dmem_b039 = PIPELINE_INST.DMEM.mem[39];
    assign o_dmem_b040 = PIPELINE_INST.DMEM.mem[40];
    assign o_dmem_b041 = PIPELINE_INST.DMEM.mem[41];
    assign o_dmem_b042 = PIPELINE_INST.DMEM.mem[42];
    assign o_dmem_b043 = PIPELINE_INST.DMEM.mem[43];
    assign o_dmem_b044 = PIPELINE_INST.DMEM.mem[44];
    assign o_dmem_b045 = PIPELINE_INST.DMEM.mem[45];
    assign o_dmem_b046 = PIPELINE_INST.DMEM.mem[46];
    assign o_dmem_b047 = PIPELINE_INST.DMEM.mem[47];
    assign o_dmem_b048 = PIPELINE_INST.DMEM.mem[48];
    assign o_dmem_b049 = PIPELINE_INST.DMEM.mem[49];
    assign o_dmem_b050 = PIPELINE_INST.DMEM.mem[50];
    assign o_dmem_b051 = PIPELINE_INST.DMEM.mem[51];
    assign o_dmem_b052 = PIPELINE_INST.DMEM.mem[52];
    assign o_dmem_b053 = PIPELINE_INST.DMEM.mem[53];
    assign o_dmem_b054 = PIPELINE_INST.DMEM.mem[54];
    assign o_dmem_b055 = PIPELINE_INST.DMEM.mem[55];
    assign o_dmem_b056 = PIPELINE_INST.DMEM.mem[56];
    assign o_dmem_b057 = PIPELINE_INST.DMEM.mem[57];
    assign o_dmem_b058 = PIPELINE_INST.DMEM.mem[58];
    assign o_dmem_b059 = PIPELINE_INST.DMEM.mem[59];
    assign o_dmem_b060 = PIPELINE_INST.DMEM.mem[60];
    assign o_dmem_b061 = PIPELINE_INST.DMEM.mem[61];
    assign o_dmem_b062 = PIPELINE_INST.DMEM.mem[62];
    assign o_dmem_b063 = PIPELINE_INST.DMEM.mem[63];
    assign o_dmem_b064 = PIPELINE_INST.DMEM.mem[64];
    assign o_dmem_b065 = PIPELINE_INST.DMEM.mem[65];
    assign o_dmem_b066 = PIPELINE_INST.DMEM.mem[66];
    assign o_dmem_b067 = PIPELINE_INST.DMEM.mem[67];
    assign o_dmem_b068 = PIPELINE_INST.DMEM.mem[68];
    assign o_dmem_b069 = PIPELINE_INST.DMEM.mem[69];
    assign o_dmem_b070 = PIPELINE_INST.DMEM.mem[70];
    assign o_dmem_b071 = PIPELINE_INST.DMEM.mem[71];
    assign o_dmem_b072 = PIPELINE_INST.DMEM.mem[72];
    assign o_dmem_b073 = PIPELINE_INST.DMEM.mem[73];
    assign o_dmem_b074 = PIPELINE_INST.DMEM.mem[74];
    assign o_dmem_b075 = PIPELINE_INST.DMEM.mem[75];
    assign o_dmem_b076 = PIPELINE_INST.DMEM.mem[76];
    assign o_dmem_b077 = PIPELINE_INST.DMEM.mem[77];
    assign o_dmem_b078 = PIPELINE_INST.DMEM.mem[78];
    assign o_dmem_b079 = PIPELINE_INST.DMEM.mem[79];
    assign o_dmem_b080 = PIPELINE_INST.DMEM.mem[80];
    assign o_dmem_b081 = PIPELINE_INST.DMEM.mem[81];
    assign o_dmem_b082 = PIPELINE_INST.DMEM.mem[82];
    assign o_dmem_b083 = PIPELINE_INST.DMEM.mem[83];
    assign o_dmem_b084 = PIPELINE_INST.DMEM.mem[84];
    assign o_dmem_b085 = PIPELINE_INST.DMEM.mem[85];
    assign o_dmem_b086 = PIPELINE_INST.DMEM.mem[86];
    assign o_dmem_b087 = PIPELINE_INST.DMEM.mem[87];
    assign o_dmem_b088 = PIPELINE_INST.DMEM.mem[88];
    assign o_dmem_b089 = PIPELINE_INST.DMEM.mem[89];
    assign o_dmem_b090 = PIPELINE_INST.DMEM.mem[90];
    assign o_dmem_b091 = PIPELINE_INST.DMEM.mem[91];
    assign o_dmem_b092 = PIPELINE_INST.DMEM.mem[92];
    assign o_dmem_b093 = PIPELINE_INST.DMEM.mem[93];
    assign o_dmem_b094 = PIPELINE_INST.DMEM.mem[94];
    assign o_dmem_b095 = PIPELINE_INST.DMEM.mem[95];
    assign o_dmem_b096 = PIPELINE_INST.DMEM.mem[96];
    assign o_dmem_b097 = PIPELINE_INST.DMEM.mem[97];
    assign o_dmem_b098 = PIPELINE_INST.DMEM.mem[98];
    assign o_dmem_b099 = PIPELINE_INST.DMEM.mem[99];
    assign o_dmem_b100 = PIPELINE_INST.DMEM.mem[100];
    assign o_dmem_b101 = PIPELINE_INST.DMEM.mem[101];
    assign o_dmem_b102 = PIPELINE_INST.DMEM.mem[102];
    assign o_dmem_b103 = PIPELINE_INST.DMEM.mem[103];
    assign o_dmem_b104 = PIPELINE_INST.DMEM.mem[104];
    assign o_dmem_b105 = PIPELINE_INST.DMEM.mem[105];
    assign o_dmem_b106 = PIPELINE_INST.DMEM.mem[106];
    assign o_dmem_b107 = PIPELINE_INST.DMEM.mem[107];
    assign o_dmem_b108 = PIPELINE_INST.DMEM.mem[108];
    assign o_dmem_b109 = PIPELINE_INST.DMEM.mem[109];
    assign o_dmem_b110 = PIPELINE_INST.DMEM.mem[110];
    assign o_dmem_b111 = PIPELINE_INST.DMEM.mem[111];
    assign o_dmem_b112 = PIPELINE_INST.DMEM.mem[112];
    assign o_dmem_b113 = PIPELINE_INST.DMEM.mem[113];
    assign o_dmem_b114 = PIPELINE_INST.DMEM.mem[114];
    assign o_dmem_b115 = PIPELINE_INST.DMEM.mem[115];
    assign o_dmem_b116 = PIPELINE_INST.DMEM.mem[116];
    assign o_dmem_b117 = PIPELINE_INST.DMEM.mem[117];
    assign o_dmem_b118 = PIPELINE_INST.DMEM.mem[118];
    assign o_dmem_b119 = PIPELINE_INST.DMEM.mem[119];
    assign o_dmem_b120 = PIPELINE_INST.DMEM.mem[120];
    assign o_dmem_b121 = PIPELINE_INST.DMEM.mem[121];
    assign o_dmem_b122 = PIPELINE_INST.DMEM.mem[122];
    assign o_dmem_b123 = PIPELINE_INST.DMEM.mem[123];
    assign o_dmem_b124 = PIPELINE_INST.DMEM.mem[124];
    assign o_dmem_b125 = PIPELINE_INST.DMEM.mem[125];
    assign o_dmem_b126 = PIPELINE_INST.DMEM.mem[126];
    assign o_dmem_b127 = PIPELINE_INST.DMEM.mem[127];
    assign o_dmem_b128 = PIPELINE_INST.DMEM.mem[128];
    assign o_dmem_b129 = PIPELINE_INST.DMEM.mem[129];
    assign o_dmem_b130 = PIPELINE_INST.DMEM.mem[130];
    assign o_dmem_b131 = PIPELINE_INST.DMEM.mem[131];
    assign o_dmem_b132 = PIPELINE_INST.DMEM.mem[132];
    assign o_dmem_b133 = PIPELINE_INST.DMEM.mem[133];
    assign o_dmem_b134 = PIPELINE_INST.DMEM.mem[134];
    assign o_dmem_b135 = PIPELINE_INST.DMEM.mem[135];
    assign o_dmem_b136 = PIPELINE_INST.DMEM.mem[136];
    assign o_dmem_b137 = PIPELINE_INST.DMEM.mem[137];
    assign o_dmem_b138 = PIPELINE_INST.DMEM.mem[138];
    assign o_dmem_b139 = PIPELINE_INST.DMEM.mem[139];
    assign o_dmem_b140 = PIPELINE_INST.DMEM.mem[140];
    assign o_dmem_b141 = PIPELINE_INST.DMEM.mem[141];
    assign o_dmem_b142 = PIPELINE_INST.DMEM.mem[142];
    assign o_dmem_b143 = PIPELINE_INST.DMEM.mem[143];
    assign o_dmem_b144 = PIPELINE_INST.DMEM.mem[144];
    assign o_dmem_b145 = PIPELINE_INST.DMEM.mem[145];
    assign o_dmem_b146 = PIPELINE_INST.DMEM.mem[146];
    assign o_dmem_b147 = PIPELINE_INST.DMEM.mem[147];
    assign o_dmem_b148 = PIPELINE_INST.DMEM.mem[148];
    assign o_dmem_b149 = PIPELINE_INST.DMEM.mem[149];
    assign o_dmem_b150 = PIPELINE_INST.DMEM.mem[150];
    assign o_dmem_b151 = PIPELINE_INST.DMEM.mem[151];
    assign o_dmem_b152 = PIPELINE_INST.DMEM.mem[152];
    assign o_dmem_b153 = PIPELINE_INST.DMEM.mem[153];
    assign o_dmem_b154 = PIPELINE_INST.DMEM.mem[154];
    assign o_dmem_b155 = PIPELINE_INST.DMEM.mem[155];
    assign o_dmem_b156 = PIPELINE_INST.DMEM.mem[156];
    assign o_dmem_b157 = PIPELINE_INST.DMEM.mem[157];
    assign o_dmem_b158 = PIPELINE_INST.DMEM.mem[158];
    assign o_dmem_b159 = PIPELINE_INST.DMEM.mem[159];
    assign o_dmem_b160 = PIPELINE_INST.DMEM.mem[160];
    assign o_dmem_b161 = PIPELINE_INST.DMEM.mem[161];
    assign o_dmem_b162 = PIPELINE_INST.DMEM.mem[162];
    assign o_dmem_b163 = PIPELINE_INST.DMEM.mem[163];
    assign o_dmem_b164 = PIPELINE_INST.DMEM.mem[164];
    assign o_dmem_b165 = PIPELINE_INST.DMEM.mem[165];
    assign o_dmem_b166 = PIPELINE_INST.DMEM.mem[166];
    assign o_dmem_b167 = PIPELINE_INST.DMEM.mem[167];
    assign o_dmem_b168 = PIPELINE_INST.DMEM.mem[168];
    assign o_dmem_b169 = PIPELINE_INST.DMEM.mem[169];
    assign o_dmem_b170 = PIPELINE_INST.DMEM.mem[170];
    assign o_dmem_b171 = PIPELINE_INST.DMEM.mem[171];
    assign o_dmem_b172 = PIPELINE_INST.DMEM.mem[172];
    assign o_dmem_b173 = PIPELINE_INST.DMEM.mem[173];
    assign o_dmem_b174 = PIPELINE_INST.DMEM.mem[174];
    assign o_dmem_b175 = PIPELINE_INST.DMEM.mem[175];
    assign o_dmem_b176 = PIPELINE_INST.DMEM.mem[176];
    assign o_dmem_b177 = PIPELINE_INST.DMEM.mem[177];
    assign o_dmem_b178 = PIPELINE_INST.DMEM.mem[178];
    assign o_dmem_b179 = PIPELINE_INST.DMEM.mem[179];
    assign o_dmem_b180 = PIPELINE_INST.DMEM.mem[180];
    assign o_dmem_b181 = PIPELINE_INST.DMEM.mem[181];
    assign o_dmem_b182 = PIPELINE_INST.DMEM.mem[182];
    assign o_dmem_b183 = PIPELINE_INST.DMEM.mem[183];
    assign o_dmem_b184 = PIPELINE_INST.DMEM.mem[184];
    assign o_dmem_b185 = PIPELINE_INST.DMEM.mem[185];
    assign o_dmem_b186 = PIPELINE_INST.DMEM.mem[186];
    assign o_dmem_b187 = PIPELINE_INST.DMEM.mem[187];
    assign o_dmem_b188 = PIPELINE_INST.DMEM.mem[188];
    assign o_dmem_b189 = PIPELINE_INST.DMEM.mem[189];
    assign o_dmem_b190 = PIPELINE_INST.DMEM.mem[190];
    assign o_dmem_b191 = PIPELINE_INST.DMEM.mem[191];
    assign o_dmem_b192 = PIPELINE_INST.DMEM.mem[192];
    assign o_dmem_b193 = PIPELINE_INST.DMEM.mem[193];
    assign o_dmem_b194 = PIPELINE_INST.DMEM.mem[194];
    assign o_dmem_b195 = PIPELINE_INST.DMEM.mem[195];
    assign o_dmem_b196 = PIPELINE_INST.DMEM.mem[196];
    assign o_dmem_b197 = PIPELINE_INST.DMEM.mem[197];
    assign o_dmem_b198 = PIPELINE_INST.DMEM.mem[198];
    assign o_dmem_b199 = PIPELINE_INST.DMEM.mem[199];
    assign o_dmem_b200 = PIPELINE_INST.DMEM.mem[200];
    assign o_dmem_b201 = PIPELINE_INST.DMEM.mem[201];
    assign o_dmem_b202 = PIPELINE_INST.DMEM.mem[202];
    assign o_dmem_b203 = PIPELINE_INST.DMEM.mem[203];
    assign o_dmem_b204 = PIPELINE_INST.DMEM.mem[204];
    assign o_dmem_b205 = PIPELINE_INST.DMEM.mem[205];
    assign o_dmem_b206 = PIPELINE_INST.DMEM.mem[206];
    assign o_dmem_b207 = PIPELINE_INST.DMEM.mem[207];
    assign o_dmem_b208 = PIPELINE_INST.DMEM.mem[208];
    assign o_dmem_b209 = PIPELINE_INST.DMEM.mem[209];
    assign o_dmem_b210 = PIPELINE_INST.DMEM.mem[210];
    assign o_dmem_b211 = PIPELINE_INST.DMEM.mem[211];
    assign o_dmem_b212 = PIPELINE_INST.DMEM.mem[212];
    assign o_dmem_b213 = PIPELINE_INST.DMEM.mem[213];
    assign o_dmem_b214 = PIPELINE_INST.DMEM.mem[214];
    assign o_dmem_b215 = PIPELINE_INST.DMEM.mem[215];
    assign o_dmem_b216 = PIPELINE_INST.DMEM.mem[216];
    assign o_dmem_b217 = PIPELINE_INST.DMEM.mem[217];
    assign o_dmem_b218 = PIPELINE_INST.DMEM.mem[218];
    assign o_dmem_b219 = PIPELINE_INST.DMEM.mem[219];
    assign o_dmem_b220 = PIPELINE_INST.DMEM.mem[220];
    assign o_dmem_b221 = PIPELINE_INST.DMEM.mem[221];
    assign o_dmem_b222 = PIPELINE_INST.DMEM.mem[222];
    assign o_dmem_b223 = PIPELINE_INST.DMEM.mem[223];
    assign o_dmem_b224 = PIPELINE_INST.DMEM.mem[224];
    assign o_dmem_b225 = PIPELINE_INST.DMEM.mem[225];
    assign o_dmem_b226 = PIPELINE_INST.DMEM.mem[226];
    assign o_dmem_b227 = PIPELINE_INST.DMEM.mem[227];
    assign o_dmem_b228 = PIPELINE_INST.DMEM.mem[228];
    assign o_dmem_b229 = PIPELINE_INST.DMEM.mem[229];
    assign o_dmem_b230 = PIPELINE_INST.DMEM.mem[230];
    assign o_dmem_b231 = PIPELINE_INST.DMEM.mem[231];
    assign o_dmem_b232 = PIPELINE_INST.DMEM.mem[232];
    assign o_dmem_b233 = PIPELINE_INST.DMEM.mem[233];
    assign o_dmem_b234 = PIPELINE_INST.DMEM.mem[234];
    assign o_dmem_b235 = PIPELINE_INST.DMEM.mem[235];
    assign o_dmem_b236 = PIPELINE_INST.DMEM.mem[236];
    assign o_dmem_b237 = PIPELINE_INST.DMEM.mem[237];
    assign o_dmem_b238 = PIPELINE_INST.DMEM.mem[238];
    assign o_dmem_b239 = PIPELINE_INST.DMEM.mem[239];
    assign o_dmem_b240 = PIPELINE_INST.DMEM.mem[240];
    assign o_dmem_b241 = PIPELINE_INST.DMEM.mem[241];
    assign o_dmem_b242 = PIPELINE_INST.DMEM.mem[242];
    assign o_dmem_b243 = PIPELINE_INST.DMEM.mem[243];
    assign o_dmem_b244 = PIPELINE_INST.DMEM.mem[244];
    assign o_dmem_b245 = PIPELINE_INST.DMEM.mem[245];
    assign o_dmem_b246 = PIPELINE_INST.DMEM.mem[246];
    assign o_dmem_b247 = PIPELINE_INST.DMEM.mem[247];
    assign o_dmem_b248 = PIPELINE_INST.DMEM.mem[248];
    assign o_dmem_b249 = PIPELINE_INST.DMEM.mem[249];
    assign o_dmem_b250 = PIPELINE_INST.DMEM.mem[250];
    assign o_dmem_b251 = PIPELINE_INST.DMEM.mem[251];
    assign o_dmem_b252 = PIPELINE_INST.DMEM.mem[252];
    assign o_dmem_b253 = PIPELINE_INST.DMEM.mem[253];
    assign o_dmem_b254 = PIPELINE_INST.DMEM.mem[254];
    assign o_dmem_b255 = PIPELINE_INST.DMEM.mem[255];
    assign o_dmem_b256 = PIPELINE_INST.DMEM.mem[256];
    assign o_dmem_b257 = PIPELINE_INST.DMEM.mem[257];
    assign o_dmem_b258 = PIPELINE_INST.DMEM.mem[258];
    assign o_dmem_b259 = PIPELINE_INST.DMEM.mem[259];
    assign o_dmem_b260 = PIPELINE_INST.DMEM.mem[260];
    assign o_dmem_b261 = PIPELINE_INST.DMEM.mem[261];
    assign o_dmem_b262 = PIPELINE_INST.DMEM.mem[262];
    assign o_dmem_b263 = PIPELINE_INST.DMEM.mem[263];
    assign o_dmem_b264 = PIPELINE_INST.DMEM.mem[264];
    assign o_dmem_b265 = PIPELINE_INST.DMEM.mem[265];
    assign o_dmem_b266 = PIPELINE_INST.DMEM.mem[266];
    assign o_dmem_b267 = PIPELINE_INST.DMEM.mem[267];
    assign o_dmem_b268 = PIPELINE_INST.DMEM.mem[268];
    assign o_dmem_b269 = PIPELINE_INST.DMEM.mem[269];
    assign o_dmem_b270 = PIPELINE_INST.DMEM.mem[270];
    assign o_dmem_b271 = PIPELINE_INST.DMEM.mem[271];
    assign o_dmem_b272 = PIPELINE_INST.DMEM.mem[272];
    assign o_dmem_b273 = PIPELINE_INST.DMEM.mem[273];
    assign o_dmem_b274 = PIPELINE_INST.DMEM.mem[274];
    assign o_dmem_b275 = PIPELINE_INST.DMEM.mem[275];
    assign o_dmem_b276 = PIPELINE_INST.DMEM.mem[276];
    assign o_dmem_b277 = PIPELINE_INST.DMEM.mem[277];
    assign o_dmem_b278 = PIPELINE_INST.DMEM.mem[278];
    assign o_dmem_b279 = PIPELINE_INST.DMEM.mem[279];
    assign o_dmem_b280 = PIPELINE_INST.DMEM.mem[280];
    assign o_dmem_b281 = PIPELINE_INST.DMEM.mem[281];
    assign o_dmem_b282 = PIPELINE_INST.DMEM.mem[282];
    assign o_dmem_b283 = PIPELINE_INST.DMEM.mem[283];
    assign o_dmem_b284 = PIPELINE_INST.DMEM.mem[284];
    assign o_dmem_b285 = PIPELINE_INST.DMEM.mem[285];
    assign o_dmem_b286 = PIPELINE_INST.DMEM.mem[286];
    assign o_dmem_b287 = PIPELINE_INST.DMEM.mem[287];
    assign o_dmem_b288 = PIPELINE_INST.DMEM.mem[288];
    assign o_dmem_b289 = PIPELINE_INST.DMEM.mem[289];
    assign o_dmem_b290 = PIPELINE_INST.DMEM.mem[290];
    assign o_dmem_b291 = PIPELINE_INST.DMEM.mem[291];
    assign o_dmem_b292 = PIPELINE_INST.DMEM.mem[292];
    assign o_dmem_b293 = PIPELINE_INST.DMEM.mem[293];
    assign o_dmem_b294 = PIPELINE_INST.DMEM.mem[294];
    assign o_dmem_b295 = PIPELINE_INST.DMEM.mem[295];
    assign o_dmem_b296 = PIPELINE_INST.DMEM.mem[296];
    assign o_dmem_b297 = PIPELINE_INST.DMEM.mem[297];
    assign o_dmem_b298 = PIPELINE_INST.DMEM.mem[298];
    assign o_dmem_b299 = PIPELINE_INST.DMEM.mem[299];
    assign o_dmem_b300 = PIPELINE_INST.DMEM.mem[300];
    assign o_dmem_b301 = PIPELINE_INST.DMEM.mem[301];
    assign o_dmem_b302 = PIPELINE_INST.DMEM.mem[302];
    assign o_dmem_b303 = PIPELINE_INST.DMEM.mem[303];
    assign o_dmem_b304 = PIPELINE_INST.DMEM.mem[304];
    assign o_dmem_b305 = PIPELINE_INST.DMEM.mem[305];
    assign o_dmem_b306 = PIPELINE_INST.DMEM.mem[306];
    assign o_dmem_b307 = PIPELINE_INST.DMEM.mem[307];
    assign o_dmem_b308 = PIPELINE_INST.DMEM.mem[308];
    assign o_dmem_b309 = PIPELINE_INST.DMEM.mem[309];
    assign o_dmem_b310 = PIPELINE_INST.DMEM.mem[310];
    assign o_dmem_b311 = PIPELINE_INST.DMEM.mem[311];
    assign o_dmem_b312 = PIPELINE_INST.DMEM.mem[312];
    assign o_dmem_b313 = PIPELINE_INST.DMEM.mem[313];
    assign o_dmem_b314 = PIPELINE_INST.DMEM.mem[314];
    assign o_dmem_b315 = PIPELINE_INST.DMEM.mem[315];
    assign o_dmem_b316 = PIPELINE_INST.DMEM.mem[316];
    assign o_dmem_b317 = PIPELINE_INST.DMEM.mem[317];
    assign o_dmem_b318 = PIPELINE_INST.DMEM.mem[318];
    assign o_dmem_b319 = PIPELINE_INST.DMEM.mem[319];
    assign o_dmem_b320 = PIPELINE_INST.DMEM.mem[320];
    assign o_dmem_b321 = PIPELINE_INST.DMEM.mem[321];
    assign o_dmem_b322 = PIPELINE_INST.DMEM.mem[322];
    assign o_dmem_b323 = PIPELINE_INST.DMEM.mem[323];
    assign o_dmem_b324 = PIPELINE_INST.DMEM.mem[324];
    assign o_dmem_b325 = PIPELINE_INST.DMEM.mem[325];
    assign o_dmem_b326 = PIPELINE_INST.DMEM.mem[326];
    assign o_dmem_b327 = PIPELINE_INST.DMEM.mem[327];
    assign o_dmem_b328 = PIPELINE_INST.DMEM.mem[328];
    assign o_dmem_b329 = PIPELINE_INST.DMEM.mem[329];
    assign o_dmem_b330 = PIPELINE_INST.DMEM.mem[330];
    assign o_dmem_b331 = PIPELINE_INST.DMEM.mem[331];
    assign o_dmem_b332 = PIPELINE_INST.DMEM.mem[332];
    assign o_dmem_b333 = PIPELINE_INST.DMEM.mem[333];
    assign o_dmem_b334 = PIPELINE_INST.DMEM.mem[334];
    assign o_dmem_b335 = PIPELINE_INST.DMEM.mem[335];
    assign o_dmem_b336 = PIPELINE_INST.DMEM.mem[336];
    assign o_dmem_b337 = PIPELINE_INST.DMEM.mem[337];
    assign o_dmem_b338 = PIPELINE_INST.DMEM.mem[338];
    assign o_dmem_b339 = PIPELINE_INST.DMEM.mem[339];
    assign o_dmem_b340 = PIPELINE_INST.DMEM.mem[340];
    assign o_dmem_b341 = PIPELINE_INST.DMEM.mem[341];
    assign o_dmem_b342 = PIPELINE_INST.DMEM.mem[342];
    assign o_dmem_b343 = PIPELINE_INST.DMEM.mem[343];
    assign o_dmem_b344 = PIPELINE_INST.DMEM.mem[344];
    assign o_dmem_b345 = PIPELINE_INST.DMEM.mem[345];
    assign o_dmem_b346 = PIPELINE_INST.DMEM.mem[346];
    assign o_dmem_b347 = PIPELINE_INST.DMEM.mem[347];
    assign o_dmem_b348 = PIPELINE_INST.DMEM.mem[348];
    assign o_dmem_b349 = PIPELINE_INST.DMEM.mem[349];
    assign o_dmem_b350 = PIPELINE_INST.DMEM.mem[350];
    assign o_dmem_b351 = PIPELINE_INST.DMEM.mem[351];
    assign o_dmem_b352 = PIPELINE_INST.DMEM.mem[352];
    assign o_dmem_b353 = PIPELINE_INST.DMEM.mem[353];
    assign o_dmem_b354 = PIPELINE_INST.DMEM.mem[354];
    assign o_dmem_b355 = PIPELINE_INST.DMEM.mem[355];
    assign o_dmem_b356 = PIPELINE_INST.DMEM.mem[356];
    assign o_dmem_b357 = PIPELINE_INST.DMEM.mem[357];
    assign o_dmem_b358 = PIPELINE_INST.DMEM.mem[358];
    assign o_dmem_b359 = PIPELINE_INST.DMEM.mem[359];
    assign o_dmem_b360 = PIPELINE_INST.DMEM.mem[360];
    assign o_dmem_b361 = PIPELINE_INST.DMEM.mem[361];
    assign o_dmem_b362 = PIPELINE_INST.DMEM.mem[362];
    assign o_dmem_b363 = PIPELINE_INST.DMEM.mem[363];
    assign o_dmem_b364 = PIPELINE_INST.DMEM.mem[364];
    assign o_dmem_b365 = PIPELINE_INST.DMEM.mem[365];
    assign o_dmem_b366 = PIPELINE_INST.DMEM.mem[366];
    assign o_dmem_b367 = PIPELINE_INST.DMEM.mem[367];
    assign o_dmem_b368 = PIPELINE_INST.DMEM.mem[368];
    assign o_dmem_b369 = PIPELINE_INST.DMEM.mem[369];
    assign o_dmem_b370 = PIPELINE_INST.DMEM.mem[370];
    assign o_dmem_b371 = PIPELINE_INST.DMEM.mem[371];
    assign o_dmem_b372 = PIPELINE_INST.DMEM.mem[372];
    assign o_dmem_b373 = PIPELINE_INST.DMEM.mem[373];
    assign o_dmem_b374 = PIPELINE_INST.DMEM.mem[374];
    assign o_dmem_b375 = PIPELINE_INST.DMEM.mem[375];
    assign o_dmem_b376 = PIPELINE_INST.DMEM.mem[376];
    assign o_dmem_b377 = PIPELINE_INST.DMEM.mem[377];
    assign o_dmem_b378 = PIPELINE_INST.DMEM.mem[378];
    assign o_dmem_b379 = PIPELINE_INST.DMEM.mem[379];
    assign o_dmem_b380 = PIPELINE_INST.DMEM.mem[380];
    assign o_dmem_b381 = PIPELINE_INST.DMEM.mem[381];
    assign o_dmem_b382 = PIPELINE_INST.DMEM.mem[382];
    assign o_dmem_b383 = PIPELINE_INST.DMEM.mem[383];
    assign o_dmem_b384 = PIPELINE_INST.DMEM.mem[384];
    assign o_dmem_b385 = PIPELINE_INST.DMEM.mem[385];
    assign o_dmem_b386 = PIPELINE_INST.DMEM.mem[386];
    assign o_dmem_b387 = PIPELINE_INST.DMEM.mem[387];
    assign o_dmem_b388 = PIPELINE_INST.DMEM.mem[388];
    assign o_dmem_b389 = PIPELINE_INST.DMEM.mem[389];
    assign o_dmem_b390 = PIPELINE_INST.DMEM.mem[390];
    assign o_dmem_b391 = PIPELINE_INST.DMEM.mem[391];
    assign o_dmem_b392 = PIPELINE_INST.DMEM.mem[392];
    assign o_dmem_b393 = PIPELINE_INST.DMEM.mem[393];
    assign o_dmem_b394 = PIPELINE_INST.DMEM.mem[394];
    assign o_dmem_b395 = PIPELINE_INST.DMEM.mem[395];
    assign o_dmem_b396 = PIPELINE_INST.DMEM.mem[396];
    assign o_dmem_b397 = PIPELINE_INST.DMEM.mem[397];
    assign o_dmem_b398 = PIPELINE_INST.DMEM.mem[398];
    assign o_dmem_b399 = PIPELINE_INST.DMEM.mem[399];
    assign o_dmem_b400 = PIPELINE_INST.DMEM.mem[400];
    assign o_dmem_b401 = PIPELINE_INST.DMEM.mem[401];
    assign o_dmem_b402 = PIPELINE_INST.DMEM.mem[402];
    assign o_dmem_b403 = PIPELINE_INST.DMEM.mem[403];
    assign o_dmem_b404 = PIPELINE_INST.DMEM.mem[404];
    assign o_dmem_b405 = PIPELINE_INST.DMEM.mem[405];
    assign o_dmem_b406 = PIPELINE_INST.DMEM.mem[406];
    assign o_dmem_b407 = PIPELINE_INST.DMEM.mem[407];
    assign o_dmem_b408 = PIPELINE_INST.DMEM.mem[408];
    assign o_dmem_b409 = PIPELINE_INST.DMEM.mem[409];
    assign o_dmem_b410 = PIPELINE_INST.DMEM.mem[410];
    assign o_dmem_b411 = PIPELINE_INST.DMEM.mem[411];
    assign o_dmem_b412 = PIPELINE_INST.DMEM.mem[412];
    assign o_dmem_b413 = PIPELINE_INST.DMEM.mem[413];
    assign o_dmem_b414 = PIPELINE_INST.DMEM.mem[414];
    assign o_dmem_b415 = PIPELINE_INST.DMEM.mem[415];
    assign o_dmem_b416 = PIPELINE_INST.DMEM.mem[416];
    assign o_dmem_b417 = PIPELINE_INST.DMEM.mem[417];
    assign o_dmem_b418 = PIPELINE_INST.DMEM.mem[418];
    assign o_dmem_b419 = PIPELINE_INST.DMEM.mem[419];
    assign o_dmem_b420 = PIPELINE_INST.DMEM.mem[420];
    assign o_dmem_b421 = PIPELINE_INST.DMEM.mem[421];
    assign o_dmem_b422 = PIPELINE_INST.DMEM.mem[422];
    assign o_dmem_b423 = PIPELINE_INST.DMEM.mem[423];
    assign o_dmem_b424 = PIPELINE_INST.DMEM.mem[424];
    assign o_dmem_b425 = PIPELINE_INST.DMEM.mem[425];
    assign o_dmem_b426 = PIPELINE_INST.DMEM.mem[426];
    assign o_dmem_b427 = PIPELINE_INST.DMEM.mem[427];
    assign o_dmem_b428 = PIPELINE_INST.DMEM.mem[428];
    assign o_dmem_b429 = PIPELINE_INST.DMEM.mem[429];
    assign o_dmem_b430 = PIPELINE_INST.DMEM.mem[430];
    assign o_dmem_b431 = PIPELINE_INST.DMEM.mem[431];
    assign o_dmem_b432 = PIPELINE_INST.DMEM.mem[432];
    assign o_dmem_b433 = PIPELINE_INST.DMEM.mem[433];
    assign o_dmem_b434 = PIPELINE_INST.DMEM.mem[434];
    assign o_dmem_b435 = PIPELINE_INST.DMEM.mem[435];
    assign o_dmem_b436 = PIPELINE_INST.DMEM.mem[436];
    assign o_dmem_b437 = PIPELINE_INST.DMEM.mem[437];
    assign o_dmem_b438 = PIPELINE_INST.DMEM.mem[438];
    assign o_dmem_b439 = PIPELINE_INST.DMEM.mem[439];
    assign o_dmem_b440 = PIPELINE_INST.DMEM.mem[440];
    assign o_dmem_b441 = PIPELINE_INST.DMEM.mem[441];
    assign o_dmem_b442 = PIPELINE_INST.DMEM.mem[442];
    assign o_dmem_b443 = PIPELINE_INST.DMEM.mem[443];
    assign o_dmem_b444 = PIPELINE_INST.DMEM.mem[444];
    assign o_dmem_b445 = PIPELINE_INST.DMEM.mem[445];
    assign o_dmem_b446 = PIPELINE_INST.DMEM.mem[446];
    assign o_dmem_b447 = PIPELINE_INST.DMEM.mem[447];
    assign o_dmem_b448 = PIPELINE_INST.DMEM.mem[448];
    assign o_dmem_b449 = PIPELINE_INST.DMEM.mem[449];
    assign o_dmem_b450 = PIPELINE_INST.DMEM.mem[450];
    assign o_dmem_b451 = PIPELINE_INST.DMEM.mem[451];
    assign o_dmem_b452 = PIPELINE_INST.DMEM.mem[452];
    assign o_dmem_b453 = PIPELINE_INST.DMEM.mem[453];
    assign o_dmem_b454 = PIPELINE_INST.DMEM.mem[454];
    assign o_dmem_b455 = PIPELINE_INST.DMEM.mem[455];
    assign o_dmem_b456 = PIPELINE_INST.DMEM.mem[456];
    assign o_dmem_b457 = PIPELINE_INST.DMEM.mem[457];
    assign o_dmem_b458 = PIPELINE_INST.DMEM.mem[458];
    assign o_dmem_b459 = PIPELINE_INST.DMEM.mem[459];
    assign o_dmem_b460 = PIPELINE_INST.DMEM.mem[460];
    assign o_dmem_b461 = PIPELINE_INST.DMEM.mem[461];
    assign o_dmem_b462 = PIPELINE_INST.DMEM.mem[462];
    assign o_dmem_b463 = PIPELINE_INST.DMEM.mem[463];
    assign o_dmem_b464 = PIPELINE_INST.DMEM.mem[464];
    assign o_dmem_b465 = PIPELINE_INST.DMEM.mem[465];
    assign o_dmem_b466 = PIPELINE_INST.DMEM.mem[466];
    assign o_dmem_b467 = PIPELINE_INST.DMEM.mem[467];
    assign o_dmem_b468 = PIPELINE_INST.DMEM.mem[468];
    assign o_dmem_b469 = PIPELINE_INST.DMEM.mem[469];
    assign o_dmem_b470 = PIPELINE_INST.DMEM.mem[470];
    assign o_dmem_b471 = PIPELINE_INST.DMEM.mem[471];
    assign o_dmem_b472 = PIPELINE_INST.DMEM.mem[472];
    assign o_dmem_b473 = PIPELINE_INST.DMEM.mem[473];
    assign o_dmem_b474 = PIPELINE_INST.DMEM.mem[474];
    assign o_dmem_b475 = PIPELINE_INST.DMEM.mem[475];
    assign o_dmem_b476 = PIPELINE_INST.DMEM.mem[476];
    assign o_dmem_b477 = PIPELINE_INST.DMEM.mem[477];
    assign o_dmem_b478 = PIPELINE_INST.DMEM.mem[478];
    assign o_dmem_b479 = PIPELINE_INST.DMEM.mem[479];
    assign o_dmem_b480 = PIPELINE_INST.DMEM.mem[480];
    assign o_dmem_b481 = PIPELINE_INST.DMEM.mem[481];
    assign o_dmem_b482 = PIPELINE_INST.DMEM.mem[482];
    assign o_dmem_b483 = PIPELINE_INST.DMEM.mem[483];
    assign o_dmem_b484 = PIPELINE_INST.DMEM.mem[484];
    assign o_dmem_b485 = PIPELINE_INST.DMEM.mem[485];
    assign o_dmem_b486 = PIPELINE_INST.DMEM.mem[486];
    assign o_dmem_b487 = PIPELINE_INST.DMEM.mem[487];
    assign o_dmem_b488 = PIPELINE_INST.DMEM.mem[488];
    assign o_dmem_b489 = PIPELINE_INST.DMEM.mem[489];
    assign o_dmem_b490 = PIPELINE_INST.DMEM.mem[490];
    assign o_dmem_b491 = PIPELINE_INST.DMEM.mem[491];
    assign o_dmem_b492 = PIPELINE_INST.DMEM.mem[492];
    assign o_dmem_b493 = PIPELINE_INST.DMEM.mem[493];
    assign o_dmem_b494 = PIPELINE_INST.DMEM.mem[494];
    assign o_dmem_b495 = PIPELINE_INST.DMEM.mem[495];
    assign o_dmem_b496 = PIPELINE_INST.DMEM.mem[496];
    assign o_dmem_b497 = PIPELINE_INST.DMEM.mem[497];
    assign o_dmem_b498 = PIPELINE_INST.DMEM.mem[498];
    assign o_dmem_b499 = PIPELINE_INST.DMEM.mem[499];
    assign o_dmem_b500 = PIPELINE_INST.DMEM.mem[500];
    assign o_dmem_b501 = PIPELINE_INST.DMEM.mem[501];
    assign o_dmem_b502 = PIPELINE_INST.DMEM.mem[502];
    assign o_dmem_b503 = PIPELINE_INST.DMEM.mem[503];
    assign o_dmem_b504 = PIPELINE_INST.DMEM.mem[504];
    assign o_dmem_b505 = PIPELINE_INST.DMEM.mem[505];
    assign o_dmem_b506 = PIPELINE_INST.DMEM.mem[506];
    assign o_dmem_b507 = PIPELINE_INST.DMEM.mem[507];
    assign o_dmem_b508 = PIPELINE_INST.DMEM.mem[508];
    assign o_dmem_b509 = PIPELINE_INST.DMEM.mem[509];
    assign o_dmem_b510 = PIPELINE_INST.DMEM.mem[510];
    assign o_dmem_b511 = PIPELINE_INST.DMEM.mem[511];

    // -- ID/EX --
    assign o_id_ex_NPC      = PIPELINE_INST.id_ex_NPC;
    assign o_id_ex_A        = PIPELINE_INST.id_ex_A;
    assign o_id_ex_B        = PIPELINE_INST.id_ex_B;
    assign o_id_ex_Imm      = PIPELINE_INST.id_ex_Imm;
    assign o_id_ex_RS       = PIPELINE_INST.id_ex_RS;
    assign o_id_ex_RT       = PIPELINE_INST.id_ex_RT;
    assign o_id_ex_RD       = PIPELINE_INST.id_ex_RD;
    assign o_id_ex_RegDst   = PIPELINE_INST.id_ex_RegDst;
    assign o_id_ex_ALUSrc   = PIPELINE_INST.id_ex_ALUSrc;
    assign o_id_ex_ALUOp    = PIPELINE_INST.id_ex_ALUOp;
    assign o_id_ex_BranchEq = PIPELINE_INST.id_ex_BranchEq;
    assign o_id_ex_BranchNe = PIPELINE_INST.id_ex_BranchNe;
    assign o_id_ex_MemRead  = PIPELINE_INST.id_ex_MemRead;
    assign o_id_ex_MemWrite = PIPELINE_INST.id_ex_MemWrite;
    assign o_id_ex_RegWrite = PIPELINE_INST.id_ex_RegWrite;
    assign o_id_ex_MemToReg = PIPELINE_INST.id_ex_MemToReg;

    // -- EX --
    assign o_forwardA        = PIPELINE_INST.forwardA;
    assign o_forwardB        = PIPELINE_INST.forwardB;
    assign o_forwardMuxA_out = PIPELINE_INST.forwardMuxA_out;
    assign o_forwardMuxB_out = PIPELINE_INST.forwardMuxB_out;
    assign o_ex_regDest      = PIPELINE_INST.ex_regDest;
    assign o_ex_aluB         = PIPELINE_INST.ex_aluB;
    assign o_ex_aluOp        = PIPELINE_INST.ex_aluOp;
    assign o_ex_aluResult    = PIPELINE_INST.ex_aluResult;
    assign o_ex_zero         = PIPELINE_INST.ex_zero;
    assign o_ex_shiftedImm   = PIPELINE_INST.ex_shiftedImm;
    assign o_ex_branchTarget = PIPELINE_INST.ex_branchTarget;

    // -- EX/MEM --
    assign o_ex_mem_BranchTarget = PIPELINE_INST.ex_mem_BranchTarget;
    assign o_ex_mem_Zero         = PIPELINE_INST.ex_mem_Zero;
    assign o_ex_mem_AluOut       = PIPELINE_INST.ex_mem_AluOut;
    assign o_ex_mem_B            = PIPELINE_INST.ex_mem_B;
    assign o_ex_mem_RD           = PIPELINE_INST.ex_mem_RD;
    assign o_ex_mem_BranchEq     = PIPELINE_INST.ex_mem_BranchEq;
    assign o_ex_mem_BranchNe     = PIPELINE_INST.ex_mem_BranchNe;
    assign o_ex_mem_MemRead      = PIPELINE_INST.ex_mem_MemRead;
    assign o_ex_mem_MemWrite     = PIPELINE_INST.ex_mem_MemWrite;
    assign o_ex_mem_RegWrite     = PIPELINE_INST.ex_mem_RegWrite;
    assign o_ex_mem_MemToReg     = PIPELINE_INST.ex_mem_MemToReg;

    // -- MEM --
    assign o_mem_PCSrc    = PIPELINE_INST.mem_PCSrc;
    assign o_mem_readData = PIPELINE_INST.mem_readData;

    // -- MEM/WB --
    assign o_mem_wb_LMD      = PIPELINE_INST.mem_wb_LMD;
    assign o_mem_wb_AluOut   = PIPELINE_INST.mem_wb_AluOut;
    assign o_mem_wb_RD       = PIPELINE_INST.mem_wb_RD;
    assign o_mem_wb_RegWrite = PIPELINE_INST.mem_wb_RegWrite;
    assign o_mem_wb_MemToReg = PIPELINE_INST.mem_wb_MemToReg;

    // -- WB --
    assign o_wb_writeData = PIPELINE_INST.wb_writeData;
    assign o_wb_regWrite  = PIPELINE_INST.wb_regWrite;
    assign o_wb_regDest   = PIPELINE_INST.wb_regDest;

endmodule
