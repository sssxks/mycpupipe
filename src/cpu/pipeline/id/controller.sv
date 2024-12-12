`include "definitions.sv"
`include "cpu_control_signals.sv"

module controller(
    input wire rst,
    // from instruction
    input wire [4:0] OPcode, // instruction[6:2]
    input wire [2:0] Fun3, // instruction[12:14]
    input wire Fun7, // instruction[30]

    input wire [31:0] instruction,

    input wire ext_int,

    // signals to datapath
    cpu_control_signals.control_unit signals_if,
    
    output reg MemRW,
    output reg [2:0] RWType
    
);
    reg [1:0] int_cause;    

    assign signals_if.IntCause = ext_int ? 2'b11 : int_cause;

    always @(*) begin
        if (rst) begin
            int_cause <= 2'b0;
            signals_if.MRet <= 1'b0;
        end else begin
            case (OPcode)
            `OPCODE_R_TYPE: begin
                signals_if.ImmSel = 3'bxxx; // doesn't matter
                signals_if.ALUSrc_B = 1'b0; // rs2
                signals_if.MemtoReg = 2'd0; // alu result
                
                signals_if.Jump = 1'b0;
                signals_if.Branch = 1'b0;
                // the following doesn't matter
                signals_if.InverseBranch = 1'bx;
                signals_if.PCOffset = 1'bx; 

                signals_if.RegWrite = 1'b1;

                MemRW = 1'b0;
                RWType = 3'b000; // doesn't matter

                int_cause = 2'b0; // doesn't cause an interruption
                signals_if.MRet = 1'b0;

                signals_if.ALU_Control = {Fun7, Fun3};
            end
            `OPCODE_IMMEDIATE_CALCULATION: begin
                signals_if.ImmSel = `IMMGEN_I;
                signals_if.ALUSrc_B = 1'b1;
                signals_if.MemtoReg = 2'd0;

                signals_if.Jump = 1'b0;
                signals_if.Branch = 1'b0;
                // the following doesn't matter
                signals_if.InverseBranch = 1'bx;
                signals_if.PCOffset = 1'bx; 

                signals_if.RegWrite = 1'b1;

                MemRW = 1'b0;
                RWType = 3'b000; // doesn't matter

                int_cause = 2'b0;
                signals_if.MRet = 1'b0;

                // I type format doesn't have Fun7
                // but shift right logical & shift right arithmatic 
                // has additional Fun6 as a special case of I type format
                signals_if.ALU_Control = {Fun3 == `FUN3_SR ? Fun7 : 1'b0, Fun3};
            end
            `OPCODE_LOAD: begin
                signals_if.ImmSel = `IMMGEN_I;
                signals_if.ALUSrc_B = 1'b1;
                signals_if.MemtoReg = 2'd1;

                signals_if.Jump = 1'b0;
                signals_if.Branch = 1'b0;
                // the following doesn't matter
                signals_if.InverseBranch = 1'bx;
                signals_if.PCOffset = 1'bx; 
                
                signals_if.RegWrite = 1'b1;

                MemRW = 1'b0;
                RWType = Fun3;

                int_cause = 2'b0;
                signals_if.MRet = 1'b0;

                signals_if.ALU_Control = `ALU_ADD;
            end
            `OPCODE_JALR: begin
                signals_if.ImmSel = `IMMGEN_I; // i type
                signals_if.ALUSrc_B = 1'b1;
                signals_if.MemtoReg = 2'd2;

                signals_if.Jump = 1'b1;
                signals_if.Branch = 1'b0;
                signals_if.InverseBranch = 1'bx;
                signals_if.PCOffset = 1'b1;
                
                signals_if.RegWrite = 1'b1;

                MemRW = 1'b0;
                RWType = 3'b000; // doesn't matter

                int_cause = 2'b0;
                signals_if.MRet = 1'b0;

                signals_if.ALU_Control = `ALU_ADD; // ADD
            end
            `OPCODE_S_TYPE: begin
                signals_if.ImmSel = `IMMGEN_S;
                signals_if.ALUSrc_B = 1'b1;
                signals_if.MemtoReg = 2'd0;
                
                signals_if.Jump = 1'b0;
                signals_if.Branch = 1'b0;
                // the following doesn't matter
                signals_if.InverseBranch = 1'bx;
                signals_if.PCOffset = 1'bx; 
                
                signals_if.RegWrite = 1'b0;

                MemRW = 1'b1;
                RWType = Fun3;

                int_cause = 2'b0;
                signals_if.MRet = 1'b0;

                signals_if.ALU_Control = `ALU_ADD; // ADD
            end
            `OPCODE_SB_TYPE: begin // SB-type branch
                signals_if.ImmSel = `IMMGEN_SB;
                signals_if.ALUSrc_B = 1'b0;
                signals_if.MemtoReg = 2'd0; // ALU result
                
                signals_if.Jump = 1'b0;
                signals_if.Branch = 1'b1;
                signals_if.InverseBranch = Fun3[0]; // NE, GE, GEU
                signals_if.PCOffset = 1'b0; 
                
                signals_if.RegWrite = 1'b0;

                MemRW = 1'b0;
                RWType = 3'b000; // doesn't matter

                signals_if.MRet = 1'b0;

                case (Fun3)
                    `FUN3_BEQ: begin
                        signals_if.ALU_Control = `ALU_EQ;
                        int_cause = 2'b0;
                    end
                    `FUN3_BNE: begin
                        signals_if.ALU_Control = `ALU_NE;
                        int_cause = 2'b0;
                    end
                    `FUN3_BLT: begin
                        signals_if.ALU_Control = `ALU_LT;
                        int_cause = 2'b0;
                    end
                    `FUN3_BGE: begin
                        signals_if.ALU_Control = `ALU_GE;
                        int_cause = 2'b1; // TODO change this back later
                    end
                    `FUN3_BLTU: begin
                        signals_if.ALU_Control = `ALU_LTU;
                        int_cause = 2'b0;
                    end
                    `FUN3_BGEU: begin
                        signals_if.ALU_Control = `ALU_GEU;
                        int_cause = 2'b0;
                    end
                    default: begin
                        signals_if.ALU_Control = 4'bxxxx; // Undefined
                        int_cause = 2'b1;
                    end
                endcase
            end
            `OPCODE_UJ_TYPE: begin // UJ-type JAL
                signals_if.ImmSel = `IMMGEN_UJ;
                signals_if.ALUSrc_B = 1'bx; // doesn't matter
                signals_if.MemtoReg = 2'd2; // PC + 4

                signals_if.Jump = 1'b1;
                signals_if.Branch = 1'b0;
                signals_if.InverseBranch = 1'bx; // doesn't matter
                signals_if.PCOffset = 1'b0; 
                
                signals_if.RegWrite = 1'b1;

                MemRW = 1'b0;
                RWType = 3'b000; // doesn't matter

                int_cause = 2'b0;
                signals_if.MRet = 1'b0;

                // this instruction doesn't use ALU
                signals_if.ALU_Control = 4'bxxxx; // Undefined
            end
            `OPCODE_LUI: begin // LUI
                signals_if.ImmSel = `IMMGEN_U;
                signals_if.ALUSrc_B = 1'bx;
                signals_if.MemtoReg = 2'd3;

                signals_if.Jump = 1'b0;
                signals_if.Branch = 1'b0;
                signals_if.InverseBranch = 1'bx; // doesn't matter
                signals_if.PCOffset = 1'b0; 

                signals_if.RegWrite = 1'b1;

                MemRW = 1'b0;
                RWType = 3'b000; // doesn't matter

                int_cause = 2'b0;
                signals_if.MRet = 1'b0;

                // this instruction doesn't use ALU
                signals_if.ALU_Control = 4'bxxxx; // Undefined
            end
            `OPCODE_AUIPC: begin // AUIPC
                signals_if.ImmSel = `IMMGEN_U;
                signals_if.ALUSrc_B = 1'bx;
                signals_if.MemtoReg = 2'd2;

                signals_if.Jump = 1'b0;
                signals_if.Branch = 1'b0;
                signals_if.InverseBranch = 1'bx; // doesn't matter
                signals_if.PCOffset = 1'b0;
                
                signals_if.RegWrite = 1'b1;

                MemRW = 1'b0;
                RWType = 3'b000; // doesn't matter

                int_cause = 2'b0;
                signals_if.MRet = 1'b0;

                // this instruction doesn't use ALU
                signals_if.ALU_Control = 4'bxxxx; // Undefined
            end
            `OPCODE_SYSTEM: begin
                signals_if.ImmSel = 3'bxxx;
                signals_if.ALUSrc_B = 1'bx;
                signals_if.MemtoReg = 2'bxx;

                signals_if.Jump = 1'b0;
                signals_if.Branch = 1'b0;
                signals_if.InverseBranch = 1'bx;
                signals_if.PCOffset = 1'bx;

                signals_if.RegWrite = 1'b0;

                MemRW = 1'b0;
                RWType = 3'bxxx;

                signals_if.ALU_Control = 4'bxxxx;
                case (instruction[31:20])
                    `FUN12_ECALL: begin
                        int_cause = 2'd2;
                        signals_if.MRet = 1'b0;
                    end
                    `FUN12_MRET: begin
                        int_cause = 2'd0;
                        signals_if.MRet = 1'b1;
                    end
                    default: begin
                        int_cause = 2'd1;
                        signals_if.MRet = 1'b0;
                    end
                endcase
            end
            default: begin // should ignore, but for now, just set to undefined
                signals_if.ImmSel = 3'bxxx;
                signals_if.ALUSrc_B = 1'bx;
                signals_if.MemtoReg = 2'bxx;

                signals_if.Jump = 1'bx;
                signals_if.Branch = 1'bx;
                signals_if.InverseBranch = 1'bx;
                signals_if.PCOffset = 1'bx; 

                signals_if.RegWrite = 1'b0;

                MemRW = 1'bx;
                RWType = 3'bxxx;

                int_cause = 2'd1;
                signals_if.MRet = 1'b0;

                signals_if.ALU_Control = 4'bxxxx;
            end
        endcase

        end
    end
endmodule
