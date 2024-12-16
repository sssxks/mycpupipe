`ifndef CONTROL_SIGNALS_H
`define CONTROL_SIGNALS_H

// package control_signals;
    typedef struct packed{
        logic [2:0] ImmSel; // select signal to immgen. i-type / s-type / sb-type / uj-type
    } id_control_t;

    typedef struct packed{
        logic [3:0] ALUControl; // ALU control signals
        logic ALUSrcB; // 0: rs2, 1: imm
        logic PCOffset; // 1: offset PC by alu result, 0: immediate value
                        // 1: jalr, 0: others
    } ex_control_t;

    typedef struct packed{
        logic MemRW;
        logic [2:0] RWType;

        logic Jump; // unconditional jump instruction
        logic Branch; // conditional jump instruction
        logic InverseBranch; // 1: invert branch condition, 0: normal branch condition
                             // only valid when Branch=1
    } mem_control_t;

    typedef struct packed{
        logic [1:0] MemtoReg; // mem2reg(load) / alu2reg(R-type) / (jalr/auipc) / immediate
        logic RegWrite; // 1: write to register
    } wb_control_t;

// endpackage

`endif // CONTROL_SIGNALS_H
