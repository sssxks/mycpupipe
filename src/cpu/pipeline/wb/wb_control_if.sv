interface wb_control_if;
    logic [1:0] MemtoReg; // mem2reg(load) / alu2reg(R-type) / (jalr/auipc) / immediate
    logic RegWrite; // 1: write to register

    modport provider (
        output MemtoReg,
        output RegWrite
    );

    modport consumer (
        input MemtoReg,
        input RegWrite
    );
endinterface //wb_control_if
