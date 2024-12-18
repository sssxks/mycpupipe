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
        id_ctrl.ImmSel = immgen_t'('x);
        ex_ctrl.ALUSrcB = 1'bx;
        wb_ctrl.MemtoReg = memtoreg_t'('x);
        mem_ctrl.Jump = 1'b0;
        ex_ctrl.Branch = 1'b0;
        ex_ctrl.InverseBranch = 1'bx;
        ex_ctrl.PCOffset = 1'bx;
        wb_ctrl.RegWrite = 1'b0;
        mem_ctrl.MemRW = 1'bx;
        mem_ctrl.RWType = 3'b000;
        ex_ctrl.ALUControl = 4'bxxxx;

        case (opcode)
        opcode_t::OPCODE_R_TYPE: begin
            ex_ctrl.ALUSrcB = 1'b0; // rs2
            wb_ctrl.MemtoReg = memtoreg_t::MEMTOREG_ALU; // alu result
            wb_ctrl.RegWrite = 1'b1;
            mem_ctrl.MemRW = 1'b0;
            ex_ctrl.ALUControl = {fun7, fun3};
        end
        opcode_t::OPCODE_IMMEDIATE_CALCULATION: begin
            id_ctrl.ImmSel = immgen_t::IMMGEN_I;
            ex_ctrl.ALUSrcB = 1'b1; // immediate
            wb_ctrl.MemtoReg = memtoreg_t::MEMTOREG_ALU; // alu result
            wb_ctrl.RegWrite = 1'b1;
            mem_ctrl.MemRW = 1'b0;
            ex_ctrl.ALUControl = {fun3 == fun3_t::FUN3_SR ? fun7 : 1'b0, fun3};
        end
        opcode_t::OPCODE_LOAD: begin
            id_ctrl.ImmSel = immgen_t::IMMGEN_I;
            ex_ctrl.ALUSrcB = 1'b1;
            wb_ctrl.MemtoReg = memtoreg_t::MEMTOREG_MEM;
            wb_ctrl.RegWrite = 1'b1;
            mem_ctrl.MemRW = 1'b0;
            mem_ctrl.RWType = fun3;
            ex_ctrl.ALUControl = alu_t::ALU_ADD;
        end
        opcode_t::OPCODE_JALR: begin
            id_ctrl.ImmSel = immgen_t::IMMGEN_I; // i type
            ex_ctrl.ALUSrcB = 1'b1;
            wb_ctrl.MemtoReg = memtoreg_t::MEMTOREG_PC;
            mem_ctrl.Jump = 1'b1;
            ex_ctrl.PCOffset = 1'b1;
            wb_ctrl.RegWrite = 1'b1;
            mem_ctrl.MemRW = 1'b0;
            ex_ctrl.ALUControl = alu_t::ALU_ADD; // ADD
        end
        opcode_t::OPCODE_S_TYPE: begin
            id_ctrl.ImmSel = immgen_t::IMMGEN_S;
            ex_ctrl.ALUSrcB = 1'b1;
            wb_ctrl.RegWrite = 1'b0;
            mem_ctrl.MemRW = 1'b1;
            mem_ctrl.RWType = fun3;
            ex_ctrl.ALUControl = alu_t::ALU_ADD; // ADD
        end
        opcode_t::OPCODE_SB_TYPE: begin // SB-type branch
            id_ctrl.ImmSel = immgen_t::IMMGEN_SB;
            ex_ctrl.ALUSrcB = 1'b0;
            wb_ctrl.MemtoReg = memtoreg_t::MEMTOREG_ALU;
            ex_ctrl.Branch = 1'b1;
            ex_ctrl.InverseBranch = fun3[0]; // NE, GE, GEU
            ex_ctrl.PCOffset = 1'b0;
            wb_ctrl.RegWrite = 1'b0;
            mem_ctrl.MemRW = 1'b0;
            case (fun3)
                fun3_branch_t::FUN3_BEQ: ex_ctrl.ALUControl = ALU_EQ;
                fun3_branch_t::FUN3_BNE: ex_ctrl.ALUControl = ALU_NE;
                fun3_branch_t::FUN3_BLT: ex_ctrl.ALUControl = ALU_LT;
                fun3_branch_t::FUN3_BGE: ex_ctrl.ALUControl = ALU_GE;
                fun3_branch_t::FUN3_BLTU: ex_ctrl.ALUControl = ALU_LTU;
                fun3_branch_t::FUN3_BGEU: ex_ctrl.ALUControl = ALU_GEU;
                default: ex_ctrl.ALUControl = 4'bxxxx; // Undefined
            endcase
        end
        opcode_t::OPCODE_UJ_TYPE: begin // UJ-type JAL
            id_ctrl.ImmSel = immgen_t::IMMGEN_UJ;
            wb_ctrl.MemtoReg = memtoreg_t::MEMTOREG_PC; // PC + 4
            mem_ctrl.Jump = 1'b1;
            ex_ctrl.PCOffset = 1'b0;
            wb_ctrl.RegWrite = 1'b1;
            mem_ctrl.MemRW = 1'b0;
        end
        opcode_t::OPCODE_LUI: begin // LUI
            id_ctrl.ImmSel = immgen_t::IMMGEN_U;
            wb_ctrl.MemtoReg = memtoreg_t::MEMTOREG_IMM;
            wb_ctrl.RegWrite = 1'b1;
            mem_ctrl.MemRW = 1'b0;
        end
        opcode_t::OPCODE_AUIPC: begin // AUIPC
            id_ctrl.ImmSel = immgen_t::IMMGEN_U;
            wb_ctrl.MemtoReg = memtoreg_t::MEMTOREG_PC; // PC + imm
            wb_ctrl.RegWrite = 1'b1;
            mem_ctrl.MemRW = 1'b0;
        end
        endcase
    end
endmodule
