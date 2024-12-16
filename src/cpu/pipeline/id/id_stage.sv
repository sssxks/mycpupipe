`timescale 1ns / 1ps
`default_nettype none
`include "control_signals.sv"

module id_stage (
    input logic clk,
    input logic reset,
    
    input logic        RegWriteIn,
    input logic [4:0]  rd_addr_in,
    input logic [31:0] rd_data,
    input logic [31:0] instr,

    output logic [31:0] rs1_data,
    output logic [31:0] rs2_data,
    output logic [31:0] rd_addr_out,
    output logic [31:0] immediate,

    output ex_control_t ex_ctrl,
    output mem_control_t mem_ctrl,
    output wb_control_t wb_ctrl

    // output logic       ALUSrcB,
    // output logic [3:0] ALUControl,
    // output logic       Branch,
    // output logic       InverseBranch,
    // output logic       Jump,
    // output logic [1:0] MemtoReg,
    // output logic       RegWriteOut

);
    id_control_t id_ctrl;

    controller ctrl (
        .rst(reset),

        .opcode(instr[6:2]),
        .fun3(instr[14:12]),
        .fun7(instr[30]),

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
endmodule