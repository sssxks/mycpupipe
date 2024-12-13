`include "definitions.sv"

module controller(
    input wire rst,
    // from instruction
    input wire [4:0] opcode, // instruction[6:2]
    input wire [2:0] fun3, // instruction[12:14]
    input wire fun7, // instruction[30]

    input wire [31:0] instruction,

    id_control_if.provider id_ctrl,
    ex_control_if.provider ex_ctrl,
    mem_control_if.provider mem_ctrl,
    wb_control_if.provider wb_ctrl,

    output reg MemRW,
    output reg [2:0] RWType
);
    always @(*) begin
        case (opcode)
        `OPCODE_R_TYPE: begin
            id_ctrl.ImmSel = 3'bxxx; // doesn't matter
            ex_ctrl.ALUSrcB = 1'b0; // rs2
            wb_ctrl.MemtoReg = 2'd0; // alu result
            
            mem_ctrl.Jump = 1'b0;
            mem_ctrl.Branch = 1'b0;
            mem_ctrl.InverseBranch = 1'bx; // doesn't matter
            ex_ctrl.PCOffset = 1'bx; // doesn't matter

            wb_ctrl.RegWrite = 1'b1;

            MemRW = 1'b0;
            RWType = 3'b000; // doesn't matter

            ex_ctrl.ALUControl = {fun7, fun3};
        end
        `OPCODE_IMMEDIATE_CALCULATION: begin
            id_ctrl.ImmSel = `IMMGEN_I;
            ex_ctrl.ALUSrcB = 1'b1;
            wb_ctrl.MemtoReg = 2'd0;

            mem_ctrl.Jump = 1'b0;
            mem_ctrl.Branch = 1'b0;
            mem_ctrl.InverseBranch = 1'bx; // doesn't matter
            ex_ctrl.PCOffset = 1'bx; // doesn't matter

            wb_ctrl.RegWrite = 1'b1;

            MemRW = 1'b0;
            RWType = 3'b000; // doesn't matter

            ex_ctrl.ALUControl = {fun3 == `FUN3_SR ? fun7 : 1'b0, fun3};
        end
        `OPCODE_LOAD: begin
            id_ctrl.ImmSel = `IMMGEN_I;
            ex_ctrl.ALUSrcB = 1'b1;
            wb_ctrl.MemtoReg = 2'd1;

            mem_ctrl.Jump = 1'b0;
            mem_ctrl.Branch = 1'b0;
            mem_ctrl.InverseBranch = 1'bx; // doesn't matter
            ex_ctrl.PCOffset = 1'bx; // doesn't matter

            wb_ctrl.RegWrite = 1'b1;

            MemRW = 1'b0;
            RWType = fun3;

            ex_ctrl.ALUControl = `ALU_ADD;
        end
        `OPCODE_JALR: begin
            id_ctrl.ImmSel = `IMMGEN_I; // i type
            ex_ctrl.ALUSrcB = 1'b1;
            wb_ctrl.MemtoReg = 2'd2;

            mem_ctrl.Jump = 1'b1;
            mem_ctrl.Branch = 1'b0;
            mem_ctrl.InverseBranch = 1'bx; // doesn't matter
            ex_ctrl.PCOffset = 1'b1;

            wb_ctrl.RegWrite = 1'b1;

            MemRW = 1'b0;
            RWType = 3'b000; // doesn't matter

            ex_ctrl.ALUControl = `ALU_ADD; // ADD
        end
        `OPCODE_S_TYPE: begin
            id_ctrl.ImmSel = `IMMGEN_S;
            ex_ctrl.ALUSrcB = 1'b1;
            wb_ctrl.MemtoReg = 2'd0;

            mem_ctrl.Jump = 1'b0;
            mem_ctrl.Branch = 1'b0;
            mem_ctrl.InverseBranch = 1'bx; // doesn't matter
            ex_ctrl.PCOffset = 1'bx; // doesn't matter

            wb_ctrl.RegWrite = 1'b0;

            MemRW = 1'b1;
            RWType = fun3;

            ex_ctrl.ALUControl = `ALU_ADD; // ADD
        end
        `OPCODE_SB_TYPE: begin // SB-type branch
            id_ctrl.ImmSel = `IMMGEN_SB;
            ex_ctrl.ALUSrcB = 1'b0;
            wb_ctrl.MemtoReg = 2'd0; // ALU result

            mem_ctrl.Jump = 1'b0;
            mem_ctrl.Branch = 1'b1;
            mem_ctrl.InverseBranch = fun3[0]; // NE, GE, GEU
            ex_ctrl.PCOffset = 1'b0;

            wb_ctrl.RegWrite = 1'b0;

            MemRW = 1'b0;
            RWType = 3'b000; // doesn't matter

            case (fun3)
                `FUN3_BEQ: ex_ctrl.ALUControl = `ALU_EQ;
                `FUN3_BNE: ex_ctrl.ALUControl = `ALU_NE;
                `FUN3_BLT: ex_ctrl.ALUControl = `ALU_LT;
                `FUN3_BGE: ex_ctrl.ALUControl = `ALU_GE;
                `FUN3_BLTU: ex_ctrl.ALUControl = `ALU_LTU;
                `FUN3_BGEU: ex_ctrl.ALUControl = `ALU_GEU;
                default: ex_ctrl.ALUControl = 4'bxxxx; // Undefined
            endcase
        end
        `OPCODE_UJ_TYPE: begin // UJ-type JAL
            id_ctrl.ImmSel = `IMMGEN_UJ;
            ex_ctrl.ALUSrcB = 1'bx; // doesn't matter
            wb_ctrl.MemtoReg = 2'd2; // PC + 4

            mem_ctrl.Jump = 1'b1;
            mem_ctrl.Branch = 1'b0;
            mem_ctrl.InverseBranch = 1'bx; // doesn't matter
            ex_ctrl.PCOffset = 1'b0;

            wb_ctrl.RegWrite = 1'b1;

            MemRW = 1'b0;
            RWType = 3'b000; // doesn't matter

            ex_ctrl.ALUControl = 4'bxxxx; // Undefined
        end
        `OPCODE_LUI: begin // LUI
            id_ctrl.ImmSel = `IMMGEN_U;
            ex_ctrl.ALUSrcB = 1'bx;
            wb_ctrl.MemtoReg = 2'd3;

            mem_ctrl.Jump = 1'b0;
            mem_ctrl.Branch = 1'b0;
            mem_ctrl.InverseBranch = 1'bx; // doesn't matter
            ex_ctrl.PCOffset = 1'b0;

            wb_ctrl.RegWrite = 1'b1;

            MemRW = 1'b0;
            RWType = 3'b000; // doesn't matter

            ex_ctrl.ALUControl = 4'bxxxx; // Undefined
        end
        `OPCODE_AUIPC: begin // AUIPC
            id_ctrl.ImmSel = `IMMGEN_U;
            ex_ctrl.ALUSrcB = 1'bx;
            wb_ctrl.MemtoReg = 2'd2;

            mem_ctrl.Jump = 1'b0;
            mem_ctrl.Branch = 1'b0;
            mem_ctrl.InverseBranch = 1'bx; // doesn't matter
            ex_ctrl.PCOffset = 1'b0;

            wb_ctrl.RegWrite = 1'b1;

            MemRW = 1'b0;
            RWType = 3'b000; // doesn't matter

            ex_ctrl.ALUControl = 4'bxxxx; // Undefined
        end
        `OPCODE_SYSTEM: begin
            id_ctrl.ImmSel = 3'bxxx;
            ex_ctrl.ALUSrcB = 1'bx;
            wb_ctrl.MemtoReg = 2'bxx;

            mem_ctrl.Jump = 1'b0;
            mem_ctrl.Branch = 1'b0;
            mem_ctrl.InverseBranch = 1'bx;
            ex_ctrl.PCOffset = 1'bx;

            wb_ctrl.RegWrite = 1'b0;

            MemRW = 1'b0;
            RWType = 3'bxxx;

            ex_ctrl.ALUControl = 4'bxxxx;
        end
        default: begin // should ignore, but for now, just set to undefined
            id_ctrl.ImmSel = 3'bxxx;
            ex_ctrl.ALUSrcB = 1'bx;
            wb_ctrl.MemtoReg = 2'bxx;

            mem_ctrl.Jump = 1'bx;
            mem_ctrl.Branch = 1'bx;
            mem_ctrl.InverseBranch = 1'bx;
            ex_ctrl.PCOffset = 1'bx;

            wb_ctrl.RegWrite = 1'b0;

            MemRW = 1'bx;
            RWType = 3'bxxx;

            ex_ctrl.ALUControl = 4'bxxxx;
        end
    endcase
    end
endmodule
