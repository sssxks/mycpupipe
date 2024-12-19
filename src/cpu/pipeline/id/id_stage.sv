`timescale 1ns / 1ps
// `default_nettype none
`include "instruction_types.sv"
`include "control_signal_types.sv"
`include "pipeline_flow_types.sv"

module id_stage (
    input logic clk,
    input logic reset,

    input if_id_flow_t inflow,
    output id_ex_flow_t outflow,
    input wb_id_backflow_t backflow,

    hazard_if.id_stage hd
);
    id_control_t id_ctrl;

    controller controller_instance (
        .opcode(opcode_t'(inflow.instr[6:2])),
        .fun3(inflow.instr[14:12]),
        .fun7(inflow.instr[30]),

        .id_ctrl(id_ctrl),
        .ex_ctrl(outflow.ex_ctrl),
        .mem_ctrl(outflow.mem_ctrl),
        .wb_ctrl(outflow.wb_ctrl)
    );

    immgen immgen_instance (
        .ImmSel(id_ctrl.ImmSel),

        .instr(inflow.instr[31:7]),
        .immediate(outflow.immediate)
    );

    regs regs_instance (
        .clk(clk),
        .rst(reset),

        .reg_write(backflow.RegWrite),
        .rs1_addr(outflow.rs1_addr),
        .rs2_addr(outflow.rs2_addr),
        .wt_addr(backflow.rd_addr),
        .wt_data(backflow.rd_data),
        .rs1_data(outflow.rs1_data),
        .rs2_data(outflow.rs2_data)
    );

    assign outflow.rs1_addr = inflow.instr[19:15];
    assign outflow.rs2_addr = inflow.instr[24:20];
    assign outflow.rd_addr = inflow.instr[11:7];
    assign outflow.pc = inflow.pc;

    // pass register names to hazard detection unit
    assign hd.id.rs1_addr = outflow.rs1_addr;
    assign hd.id.rs2_addr = outflow.rs2_addr;
    assign hd.id.opcode = opcode_t'(inflow.instr[6:2]);
endmodule