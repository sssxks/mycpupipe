`timescale 1ns / 1ps
`default_nettype none
`include "control_signals.sv"
`include "pipeline_flow.sv"

module id_stage (
    input logic clk,
    input logic reset,

    input if_id_flow_t inflow,
    output id_ex_flow_t outflow,

    // from wb
    input logic        RegWrite,
    input logic [4:0]  rd_addr,
    input logic [31:0] rd_data
);
    id_control_t id_ctrl;

    controller ctrl (
        .rst(reset),

        .opcode(inflow.instr[6:2]),
        .fun3(inflow.instr[14:12]),
        .fun7(inflow.instr[30]),

        .id_ctrl(id_ctrl),
        .ex_ctrl(outflow.ex_ctrl),
        .mem_ctrl(outflow.mem_ctrl),
        .wb_ctrl(outflow.wb_ctrl)
    );

    immgen imm_gen (
        .ImmSel(id_ctrl.ImmSel),

        .instr(inflow.instr),
        .imm_out(outflow.immediate)
    );

    regs register_file (
        .clk(clk),
        .rst(reset),

        .reg_write(RegWrite),
        .rs1_addr(inflow.instr[19:15]),
        .rs2_addr(inflow.instr[24:20]),
        .wt_addr(rd_addr),
        .wt_data(rd_data),
        .rs1_data(outflow.rs1_data),
        .rs2_data(outflow.rs2_data)
    );

    assign outflow.rd_addr = inflow.instr[11:7];
    assign outflow.pc = inflow.pc;
endmodule