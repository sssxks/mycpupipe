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
    input logic [31:0] rd_data,

    hazard_if.id_stage hd
);
    // control signals used internally
    id_control_t id_ctrl;
    ex_control_t ex_ctrl;
    mem_control_t mem_ctrl;
    wb_control_t wb_ctrl;

    assign outflow.rs1_addr = inflow.instr[19:15];
    assign outflow.rs2_addr = outflow.ex_ctrl.ALUSrcB ? 0 : inflow.instr[24:20];
    assign outflow.rd_addr = inflow.instr[11:7];
    assign outflow.pc = inflow.pc;

    controller controller_instance (
        .opcode(inflow.instr[6:2]),
        .fun3(inflow.instr[14:12]),
        .fun7(inflow.instr[30]),

        .id_ctrl(id_ctrl),
        .ex_ctrl(ex_ctrl),
        .mem_ctrl(mem_ctrl),
        .wb_ctrl(wb_ctrl)
    );

    immgen immgen_instance (
        .ImmSel(id_ctrl.ImmSel),

        .instr(inflow.instr[31:7]),
        .immediate(outflow.immediate)
    );

    regs regs_instance (
        .clk(clk),
        .rst(reset),

        .reg_write(RegWrite),
        .rs1_addr(outflow.rs1_addr),
        .rs2_addr(outflow.rs2_addr),
        .wt_addr(rd_addr),
        .wt_data(rd_data),
        .rs1_data(outflow.rs1_data),
        .rs2_data(outflow.rs2_data)
    );

    assign hd.id.rs1_addr = outflow.rs1_addr;
    assign hd.id.rs2_addr = outflow.rs2_addr;

    always_comb begin
        if (hd.Stall) begin
            outflow.ex_ctrl = NOP_EX_CTRL;
            outflow.mem_ctrl = NOP_MEM_CTRL;
            outflow.wb_ctrl = NOP_WB_CTRL;
        end else begin
            outflow.ex_ctrl = ex_ctrl;
            outflow.mem_ctrl = mem_ctrl;
            outflow.wb_ctrl = wb_ctrl;
        end
    end
endmodule