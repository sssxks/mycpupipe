`timescale 1ns/1ps

module cpu (
    
);
    if_stage if_stage_instance (
        .clk(clk),
        .reset(reset),
        .enable(enable),
        .pc_in(pc_in),
        .PCSrc(PCSrc),
        .pc_out(pc_out)
    );

    id_stage id_stage_instance (
        .clk(clk),
        .reset(reset),
        .RegWriteIn(RegWriteIn),
        .rd_addr_in(rd_addr_in),
        .rd_data(rd_data),
        .instr(instr),
        .rs1_data(rs1_data),
        .rs2_data(rs2_data),
        .rd_addr_out(rd_addr_out),
        .immediate(immediate),
        .ALUSrcB(ALUSrcB),
        .ALUControl(ALUControl),
        .MemRW(MemRW),
        .RWType(RWType),
        .Branch(Branch),
        .InverseBranch(InverseBranch),
        .Jump(Jump),
        .MemtoReg(MemtoReg),
        .RegWriteOut(RegWriteOut)
    );
endmodule