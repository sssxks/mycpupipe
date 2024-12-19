`ifndef CONTROL_SIGNAL_TYPES_SV
`define CONTROL_SIGNAL_TYPES_SV

`include "instruction_types.sv"

// package control_signals;
// alu control
typedef enum logic [3:0] {
    ALU_ADD = 4'b0_000,
    ALU_SUB = 4'b1_000,
    ALU_SLL = 4'b0_001,
    ALU_SLT = 4'b0_010,
    ALU_SLTU = 4'b0_011,
    ALU_XOR = 4'b0_100,
    ALU_SRL = 4'b0_101,
    ALU_SRA = 4'b1_101,
    ALU_OR = 4'b0_110,
    ALU_AND = 4'b0_111
} alu_t;

const alu_t ALU_EQ = ALU_SUB;
const alu_t ALU_NE = ALU_SUB;
const alu_t ALU_LT = ALU_SLT;
const alu_t ALU_GE = ALU_SLT;
const alu_t ALU_LTU = ALU_SLTU;
const alu_t ALU_GEU = ALU_SLTU;

typedef enum logic [2:0] {
    IMMGEN_I = 3'b000, // i-type
    IMMGEN_S = 3'b001, // s-type
    IMMGEN_SB = 3'b010, // sb-type
    IMMGEN_UJ = 3'b011, // uj-type
    IMMGEN_U = 3'b100  // u-type
} immgen_t;

// RW length and sign, same as fun3 for load/store
typedef enum logic [2:0] {
    BYTE = FUN3_LB,
    BYTE_U = FUN3_LBU,
    HALF = FUN3_LH,
    HALF_U = FUN3_LHU,
    WORD = FUN3_LW
} rw_type_t;

typedef enum logic [1:0] {
    MEMTOREG_ALU = 2'd0,  // alu result (R-type)
    MEMTOREG_MEM = 2'd1,  // memory data in (load)
    MEMTOREG_PC = 2'd2,   // pc related (jalr/auipc)
    MEMTOREG_IMM = 2'd3   // immediate (lui)
} memtoreg_t;

typedef enum logic {
    OFFSET_PC = 1'b1, // offset PC by alu result (jalr)
    OFFSET_IMM = 1'b0 // offset PC by immediate value (others)
} pcoffset_t;

// conditional jump instruction
typedef enum logic {
    BRANCH_IS = 1'b1, // is a branch instruction
    BRANCH_NO = 1'b0  // not a branch instruction
} branch_t;

// only valid when Branch=1
typedef enum logic {
    INVERSE_BRANCH = 1'b1,  // bne, bge, bgeu
    NORMAL_BRANCH = 1'b0    // beq, blt, bltu
} inversebranch_t;

typedef enum logic {
    MEM_WRITE = 1'b1,  // write to memory
    MEM_READ = 1'b0    // read from memory
} memrw_t;

typedef enum logic {
    ALU_RS2 = 1'b0,   // use rs2 as ALU input b
    ALU_IMM = 1'b1    // use immediate as ALU input b
} alusrcb_t;

// unconditional jump instruction
typedef enum logic {
    JUMP = 1'b1,    // is a jump instruction
    NO_JUMP = 1'b0  // not a jump instruction
} jump_t;

// RegWrite
typedef enum logic {
    REG_WRITE = 1'b1,   // write to register
    NO_REG_WRITE = 1'b0 // not write to register
} regwrite_t;

// notice xx_control_t can be used in all stage prior xx stage, not only xx stage

typedef struct packed{
    immgen_t ImmSel;
} id_control_t;

typedef struct packed{
    alu_t ALUControl;
    alusrcb_t ALUSrcB;

    pcoffset_t PCOffset; 
    branch_t Branch;
    inversebranch_t InverseBranch; 
                                   
} ex_control_t;

typedef struct packed{
    memrw_t MemRW;
    rw_type_t RWType;

    jump_t Jump; // mainly used in ex stage, but mem stage also need it
} mem_control_t;

typedef struct packed{
    memtoreg_t MemtoReg; 
    regwrite_t RegWrite;
} wb_control_t;

// control signals for nop
// used as default values in controller, and overrider when flush or stall
// mainly choosed based on addi zero, zero, 0
// but MemRW, Jump, Branch, RegWrite are set to 0 to avoid any side effects
const id_control_t NOP_ID_CTRL = '{
    ImmSel: IMMGEN_I
};
const ex_control_t NOP_EX_CTRL = '{
    ALUControl: ALU_ADD,
    ALUSrcB: ALU_RS2,
    PCOffset: OFFSET_IMM,
    Branch: BRANCH_NO,
    InverseBranch: NORMAL_BRANCH
}; 
const mem_control_t NOP_MEM_CTRL = '{
    MemRW: MEM_READ,
    RWType: BYTE,
    Jump: NO_JUMP
};
const wb_control_t NOP_WB_CTRL = '{
    MemtoReg: MEMTOREG_ALU,
    RegWrite: NO_REG_WRITE
};

// endpackage

`endif // CONTROL_SIGNAL_TYPES_SV
