`timescale 1ns/1ps
`include "instruction_types.sv"
`include "control_signal_types.sv"

module controller(    
    // from instruction
    input wire opcode_t  opcode, // instruction[6:2]
    input wire [2:0]     fun3, // instruction[12:14]
    input wire           fun7, // instruction[30]

    output id_control_t  id_ctrl,
    output ex_control_t  ex_ctrl,
    output mem_control_t mem_ctrl,
    output wb_control_t  wb_ctrl
);
    always_comb begin
        id_ctrl = NOP_ID_CTRL;
        ex_ctrl = NOP_EX_CTRL;
        mem_ctrl = NOP_MEM_CTRL;
        wb_ctrl = NOP_WB_CTRL;

        case (opcode)
        OPCODE_R_TYPE: begin
            ex_ctrl.ALUSrcB = ALU_RS2;
            wb_ctrl.MemtoReg = MEMTOREG_ALU;
            wb_ctrl.RegWrite = REG_WRITE;
            mem_ctrl.MemRW = MEM_READ;
            ex_ctrl.ALUControl = alu_t'({fun7, fun3});
        end
        OPCODE_IMMEDIATE_CALCULATION: begin
            id_ctrl.ImmSel = IMMGEN_I;
            ex_ctrl.ALUSrcB = ALU_IMM;
            wb_ctrl.MemtoReg = MEMTOREG_ALU;
            wb_ctrl.RegWrite = REG_WRITE;
            mem_ctrl.MemRW = MEM_READ;
            ex_ctrl.ALUControl = alu_t'({fun3 == FUN3_SR ? fun7 : 1'b0, fun3});
        end
        OPCODE_LOAD: begin
            id_ctrl.ImmSel = IMMGEN_I;
            ex_ctrl.ALUSrcB = ALU_IMM;
            wb_ctrl.MemtoReg = MEMTOREG_MEM;
            wb_ctrl.RegWrite = REG_WRITE;
            mem_ctrl.MemRW = MEM_READ;
            mem_ctrl.RWType = rw_length_t'(fun3);
            ex_ctrl.ALUControl = ALU_ADD;
        end
        OPCODE_JALR: begin
            id_ctrl.ImmSel = IMMGEN_I;
            ex_ctrl.ALUSrcB = ALU_IMM;
            wb_ctrl.MemtoReg = MEMTOREG_PC;
            mem_ctrl.Jump = JUMP;
            ex_ctrl.PCOffset = OFFSET_PC;
            wb_ctrl.RegWrite = REG_WRITE;
            mem_ctrl.MemRW = MEM_READ;
            ex_ctrl.ALUControl = ALU_ADD;
        end
        OPCODE_S_TYPE: begin
            id_ctrl.ImmSel = IMMGEN_S;
            ex_ctrl.ALUSrcB = ALU_IMM;
            wb_ctrl.RegWrite = NO_REG_WRITE;
            mem_ctrl.MemRW = MEM_WRITE;
            mem_ctrl.RWType = rw_length_t'(fun3);
            ex_ctrl.ALUControl = ALU_ADD;
        end
        OPCODE_SB_TYPE: begin
            id_ctrl.ImmSel = IMMGEN_SB;
            ex_ctrl.ALUSrcB = ALU_RS2;
            wb_ctrl.MemtoReg = MEMTOREG_ALU;
            ex_ctrl.Branch = BRANCH_IS;
            ex_ctrl.InverseBranch = inversebranch_t'(fun3[0]); // NE, GE, GEU
            ex_ctrl.PCOffset = OFFSET_IMM;
            wb_ctrl.RegWrite = NO_REG_WRITE;
            mem_ctrl.MemRW = MEM_READ;
            case (fun3)
                FUN3_BEQ: ex_ctrl.ALUControl = ALU_EQ;
                FUN3_BNE: ex_ctrl.ALUControl = ALU_NE;
                FUN3_BLT: ex_ctrl.ALUControl = ALU_LT;
                FUN3_BGE: ex_ctrl.ALUControl = ALU_GE;
                FUN3_BLTU: ex_ctrl.ALUControl = ALU_LTU;
                FUN3_BGEU: ex_ctrl.ALUControl = ALU_GEU;
                default: ex_ctrl.ALUControl = alu_t'('x);
            endcase
        end
        OPCODE_UJ_TYPE: begin
            id_ctrl.ImmSel = IMMGEN_UJ;
            wb_ctrl.MemtoReg = MEMTOREG_PC; // PC + 4
            mem_ctrl.Jump = JUMP;
            ex_ctrl.PCOffset = OFFSET_IMM;
            wb_ctrl.RegWrite = REG_WRITE;
            mem_ctrl.MemRW = MEM_READ;
        end
        OPCODE_LUI: begin
            id_ctrl.ImmSel = IMMGEN_U;
            wb_ctrl.MemtoReg = MEMTOREG_IMM;
            wb_ctrl.RegWrite = REG_WRITE;
            mem_ctrl.MemRW = MEM_READ;
        end
        OPCODE_AUIPC: begin
            id_ctrl.ImmSel = IMMGEN_U;
            wb_ctrl.MemtoReg = MEMTOREG_PC; // PC + imm
            wb_ctrl.RegWrite = REG_WRITE;
            mem_ctrl.MemRW = MEM_READ;
        end
        endcase
    end
endmodule
