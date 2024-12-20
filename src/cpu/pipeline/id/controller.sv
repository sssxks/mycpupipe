`timescale 1ns/1ps
`include "instruction_types.sv"
`include "control_signal_types.sv"

module controller(    
    input wire opcode_t  opcode,
    input wire [2:0]     fun3,
    input wire           fun7, 

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
            ex_ctrl.ALUControl = alu_t'({fun7, fun3});
            wb_ctrl.RegWrite = REG_WRITE;
            wb_ctrl.MemtoReg = MEMTOREG_ALU;
        end
        OPCODE_IMMEDIATE_CALCULATION: begin
            id_ctrl.ImmSel = IMMGEN_I;
            ex_ctrl.ALUSrcB = ALU_IMM;
            ex_ctrl.ALUControl = alu_t'({fun3 == FUN3_SR ? fun7 : 1'b0, fun3});
            wb_ctrl.RegWrite = REG_WRITE;
            wb_ctrl.MemtoReg = MEMTOREG_ALU;
        end
        OPCODE_LOAD: begin
            id_ctrl.ImmSel = IMMGEN_I;
            ex_ctrl.ALUSrcB = ALU_IMM;
            ex_ctrl.ALUControl = ALU_ADD;
            mem_ctrl.MemRW = MEM_READ;
            mem_ctrl.RWType = rw_type_t'(fun3);
            wb_ctrl.RegWrite = REG_WRITE;
            wb_ctrl.MemtoReg = MEMTOREG_MEM;
        end
        OPCODE_JALR: begin
            id_ctrl.ImmSel = IMMGEN_I;
            ex_ctrl.ALUSrcB = ALU_IMM;
            ex_ctrl.ALUControl = ALU_ADD;
            ex_ctrl.PCTarget = SET_ALU;
            mem_ctrl.Jump = JUMP;
            wb_ctrl.RegWrite = REG_WRITE;
            wb_ctrl.MemtoReg = MEMTOREG_PC; // PC + 4
        end
        OPCODE_S_TYPE: begin
            id_ctrl.ImmSel = IMMGEN_S;
            ex_ctrl.ALUSrcB = ALU_IMM;
            ex_ctrl.ALUControl = ALU_ADD;
            mem_ctrl.MemRW = MEM_WRITE;
            mem_ctrl.RWType = rw_type_t'(fun3);
        end
        OPCODE_SB_TYPE: begin
            id_ctrl.ImmSel = IMMGEN_SB;
            ex_ctrl.ALUSrcB = ALU_RS2;
            case (fun3)
                FUN3_BEQ: ex_ctrl.ALUControl = ALU_EQ;
                FUN3_BNE: ex_ctrl.ALUControl = ALU_NE;
                FUN3_BLT: ex_ctrl.ALUControl = ALU_LT;
                FUN3_BGE: ex_ctrl.ALUControl = ALU_GE;
                FUN3_BLTU: ex_ctrl.ALUControl = ALU_LTU;
                FUN3_BGEU: ex_ctrl.ALUControl = ALU_GEU;
            endcase
            ex_ctrl.Branch = BRANCH;
            ex_ctrl.InverseBranch = inversebranch_t'(fun3[0]); // BNE, BGE, BGEU
            ex_ctrl.PCTarget = OFFSET_IMM;
        end
        OPCODE_UJ_TYPE: begin
            id_ctrl.ImmSel = IMMGEN_UJ;
            ex_ctrl.PCTarget = OFFSET_IMM;
            mem_ctrl.Jump = JUMP;
            wb_ctrl.RegWrite = REG_WRITE;
            wb_ctrl.MemtoReg = MEMTOREG_PC; // PC + 4
        end
        OPCODE_LUI: begin
            id_ctrl.ImmSel = IMMGEN_U;
            wb_ctrl.RegWrite = REG_WRITE;
            wb_ctrl.MemtoReg = MEMTOREG_IMM;
        end
        OPCODE_AUIPC: begin
            id_ctrl.ImmSel = IMMGEN_U;
            ex_ctrl.PCTarget = OFFSET_IMM;
            wb_ctrl.RegWrite = REG_WRITE;
            wb_ctrl.MemtoReg = MEMTOREG_PC; // PC + imm
        end
        endcase
    end
endmodule