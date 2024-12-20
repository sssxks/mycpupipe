`ifndef INSTRUCTION_TYPES_SV
`define INSTRUCTION_TYPES_SV

// DEFINITIONS for RV32I

// opcode
typedef enum logic [4:0] {
    OPCODE_R_TYPE = 5'b01100,
    OPCODE_IMMEDIATE_CALCULATION = 5'b00100,
    OPCODE_LOAD = 5'b00000,
    OPCODE_JALR = 5'b11001,
    OPCODE_S_TYPE = 5'b01000,
    OPCODE_SB_TYPE = 5'b11000,
    OPCODE_UJ_TYPE = 5'b11011, // jal
    OPCODE_LUI = 5'b01101,
    OPCODE_AUIPC = 5'b00101,
    OPCODE_SYSTEM = 5'b11100
} opcode_t;

// fun3, fun7/fun6 for R-type & immediate calculation
// also the ALU control for corresponding instructions
typedef enum logic [2:0] {
    FUN3_ADD = 3'b000,
    FUN3_SLL = 3'b001,
    FUN3_SLT = 3'b010,
    FUN3_SLTU = 3'b011,
    FUN3_XOR = 3'b100,
    FUN3_SR = 3'b101,
    FUN3_OR = 3'b110,
    FUN3_AND = 3'b111
} fun3_t;

typedef enum logic [3:0] {
    FUN_ADD = 4'b0_000,
    FUN_SUB = 4'b1_000,
    FUN_SLL = 4'b0_001,
    FUN_SLT = 4'b0_010,
    FUN_SLTU = 4'b0_011,
    FUN_XOR = 4'b0_100,
    FUN_SRL = 4'b0_101,
    FUN_SRA = 4'b1_101,
    FUN_OR = 4'b0_110,
    FUN_AND = 4'b0_111
} fun_t;

// fun3 for load
typedef enum logic [2:0] {
    FUN3_LW = 3'b010,
    FUN3_LH = 3'b001,
    FUN3_LHU = 3'b101,
    FUN3_LB = 3'b000,
    FUN3_LBU = 3'b100
} fun3_load_t;

// fun3 for store
typedef enum logic [2:0] {
    FUN3_SW = 3'b010,
    FUN3_SH = 3'b001,
    FUN3_SB = 3'b000
} fun3_store_t;

// fun3 for jalr
// actually not useful, because opcode is already used to distinguish jalr
typedef enum logic [2:0] {
    FUN3_JALR = 3'b000
} fun3_jalr_t;

// no fun3 for U-type

// fun3 for branch
typedef enum logic [2:0] {
    FUN3_BEQ = 3'b000,
    FUN3_BNE = 3'b001,
    FUN3_BLT = 3'b100,
    FUN3_BGE = 3'b101,
    FUN3_BLTU = 3'b110,
    FUN3_BGEU = 3'b111
} fun3_branch_t;

// no fun3 for UJ-type (only jal)

// fun12 for system
typedef enum logic [11:0] {
    FUN12_ECALL = 12'b0000000_00000,
    FUN12_EBREAK = 12'b0000000_00001,
    FUN12_MRET = 12'b0011000_00010,
    FUN12_SRET = 12'b0001000_00010,
    FUN12_WFI = 12'b0001000_00101
} fun12_system_t;

const logic [31:0] NOP_INSTR = 32'h00000013;

`endif // FORWARDING_TYPES_SV