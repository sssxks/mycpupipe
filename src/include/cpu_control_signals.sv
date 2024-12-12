interface cpu_control_signals;
    logic [3:0] ALUControl; // ALU control signals
    logic [2:0] ImmSel; // select signal to immgen. i-type / s-type / sb-type / uj-type
    logic [1:0] MemtoReg; // mem2reg(load) / alu2reg(R-type) / (jalr/auipc) / immediate
    logic ALUSrcB; // 0: rs2, 1: imm
    logic Jump; // unconditional jump instruction
    logic Branch; // conditional jump instruction
    logic InverseBranch; // 1: invert branch condition, 0: normal branch condition
                              // only vaild when Branch=1
    logic PCOffset; // 1: offset PC by alu result, 0: immediate value
                         // 1: jalr, 0: others
    logic RegWrite; // 1: write to register

    logic [1:0] IntCause;
    logic MRet;

    modport control_unit (
        output ALUControl,
        output ImmSel,
        output MemtoReg,
        output ALUSrcB,
        output Jump,
        output Branch,
        output InverseBranch,
        output PCOffset,
        output RegWrite,
        output IntCause,
        output MRet
    );

    modport datapath (
        input ALUControl,
        input ImmSel,
        input MemtoReg,
        input ALUSrcB,
        input Jump,
        input Branch,
        input InverseBranch,
        input PCOffset,
        input RegWrite,
        input IntCause,
        input MRet
    );

endinterface //cpu_control_signals