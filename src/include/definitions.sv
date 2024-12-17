// DEFINITIONS for RV32I

// opcode
`define OPCODE_R_TYPE 5'b01100
`define OPCODE_IMMEDIATE_CALCULATION 5'b00100
`define OPCODE_LOAD 5'b00000
`define OPCODE_JALR 5'b11001
`define OPCODE_S_TYPE 5'b01000
`define OPCODE_SB_TYPE 5'b11000
`define OPCODE_UJ_TYPE 5'b11011
`define OPCODE_LUI 5'b01101
`define OPCODE_AUIPC 5'b00101
`define OPCODE_SYSTEM 5'b11100

// fun3, fun7/fun6 for R-type & immediate calculation
// also the ALU control for corresponding instructions
`define FUN3_ADD 3'b000
`define FUN3_SLL 3'b001
`define FUN3_SLT 3'b010
`define FUN3_SLTU 3'b011
`define FUN3_XOR 3'b100
`define FUN3_SR 3'b101
`define FUN3_OR 3'b110
`define FUN3_AND 3'b111

`define FUN7_ADD 1'b0
`define FUN7_SUB 1'b1
`define FUN7_SLL 1'b0
`define FUN7_SLT 1'b0
`define FUN7_SLTU 1'b0
`define FUN7_XOR 1'b0
`define FUN7_SRL 1'b0
`define FUN7_SRA 1'b1
`define FUN7_OR 1'b0
`define FUN7_AND 1'b0

`define FUN_ADD 4'b0_000
`define FUN_SUB 4'b1_000
`define FUN_SLL 4'b0_001
`define FUN_SLT 4'b0_010
`define FUN_SLTU 4'b0_011
`define FUN_XOR 4'b0_100
`define FUN_SRL 4'b0_101
`define FUN_SRA 4'b1_101
`define FUN_OR 4'b0_110
`define FUN_AND 4'b0_111

// fun3 for load
`define FUN3_LW 3'b010
`define FUN3_LH 3'b001
`define FUN3_LHU 3'b101
`define FUN3_LB 3'b000
`define FUN3_LBU 3'b100

// fun3 for store
`define FUN3_SW 3'b010
`define FUN3_SH 3'b001
`define FUN3_SB 3'b000

// fun3 for jalr
// actually not useful, because opcode is already used to distinguish jalr
`define FUN3_JALR 3'b000

// no fun3 for U-type

// fun3 for branch
`define FUN3_BEQ 3'b000
`define FUN3_BNE 3'b001
`define FUN3_BLT 3'b100
`define FUN3_BGE 3'b101
`define FUN3_BLTU 3'b110
`define FUN3_BGEU 3'b111

// no fun3 for UJ-type (only jal)

// fun12 for system
`define FUN12_ECALL 12'b0000000_00000
`define FUN12_EBREAK 12'b0000000_00001
`define FUN12_MRET 12'b0011000_00010
`define FUN12_SRET 12'b0001000_00010
`define FUN12_WFI 12'b0001000_00101

// alu control
`define ALU_ADD 4'b0_000
`define ALU_SUB 4'b1_000
`define ALU_SLL 4'b0_001
`define ALU_SLT 4'b0_010
`define ALU_SLTU 4'b0_011
`define ALU_XOR 4'b0_100
`define ALU_SRL 4'b0_101
`define ALU_SRA 4'b1_101
`define ALU_OR 4'b0_110
`define ALU_AND 4'b0_111

`define ALU_EQ `ALU_SUB
`define ALU_NE `ALU_SUB
`define ALU_LT `ALU_SLT
`define ALU_GE `ALU_SLT
`define ALU_LTU `ALU_SLTU
`define ALU_GEU `ALU_SLTU

// immgen
`define IMMGEN_I 3'b000
`define IMMGEN_S 3'b001
`define IMMGEN_SB 3'b010
`define IMMGEN_UJ 3'b011
`define IMMGEN_U 3'b100

// RW length and sign, same as fun3 for load/store
`define BYTE   3'b000
`define BYTE_U 3'b100
`define HALF   3'b001
`define HALF_U 3'b101
`define WORD   3'b010
