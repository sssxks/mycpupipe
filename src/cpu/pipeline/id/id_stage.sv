`timescale 1ns / 1ps
`default_nettype none
`include "definitions.sv"

module id_stage (
    input  logic clk,
    input  logic reset,
    
    input logic        RegWriteIn,
    input logic [4:0]  rd_addr_in,
    input logic [31:0] rd_data,
    input logic [31:0] instr,

    output logic [31:0] rs1_data,
    output logic [31:0] rs2_data,
    output logic [31:0] rd_addr_out,
    output logic [31:0] immediate,

    ex_control_if.provider ex_ctrl,
    mem_control_if.provider mem_ctrl,
    wb_control_if.provider wb_ctrl
    // output logic       MemRW,
    // output logic       RWType,

    // output logic       ALUSrcB,
    // output logic [3:0] ALUControl,
    // output logic       Branch,
    // output logic       InverseBranch,
    // output logic       Jump,
    // output logic [1:0] MemtoReg,
    // output logic       RegWriteOut

);
    // 自己控自己
    id_control_if id_ctrl();

    controller ctrl (
        .rst(reset),
        .opcode(instr[6:2]),
        .fun3(instr[14:12]),
        .fun7(instr[30]),
        .instruction(instr),
        .ext_int(1'b0),
        .MemRW(MemRW),
        .RWType(RWType),
        .id_ctrl(id_ctrl),
        .ex_ctrl(ex_ctrl),
        .mem_ctrl(mem_ctrl),
        .wb_ctrl(wb_ctrl)

    );

    immgen imm_gen (
        .ImmSel(id_ctrl.ImmSel),
        .instr(instr),
        .imm_out(immediate)
    );

    regs register_file (
        .clk(clk),
        .rst(reset),
        .reg_write(RegWriteIn),
        .rs1_addr(instr[19:15]),
        .rs2_addr(instr[24:20]),
        .wt_addr(rd_addr_in),
        .wt_data(rd_data),
        .rs1_data(rs1_data),
        .rs2_data(rs2_data)
    );

    // assign ALUSrcB = control_signals.ALUSrcB;
    // assign ALUControl = control_signals.ALUControl;
    // assign Branch = control_signals.Branch;
    // assign InverseBranch = control_signals.InverseBranch;
    // assign Jump = control_signals.Jump;
    // assign MemtoReg = control_signals.MemtoReg;
    // assign RegWriteOut = control_signals.RegWrite;

endmodule