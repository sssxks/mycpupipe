interface ex_control_if;
    logic [3:0] ALUControl; // ALU control signals
    logic ALUSrcB; // 0: rs2, 1: imm
    logic PCOffset; // 1: offset PC by alu result, 0: immediate value
                    // 1: jalr, 0: others

    modport provider (
        output ALUControl,
        output ALUSrcB,
        output PCOffset
    );

    modport consumer (
        input ALUControl,
        input ALUSrcB,
        input PCOffset
    );
endinterface //ex_control_if
