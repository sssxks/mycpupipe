`timescale 1ns/1ps
`default_nettype none
`include "pipeline_flow.sv"

module ex_stage (
    input id_ex_flow_t inflow,
    output ex_mem_flow_t outflow
);
    alu alu_instance (
        .a(inflow.rs1_data),
        .b(inflow.ex_ctrl.ALUSrcB ?
           inflow.immediate : inflow.rs2_data),
        .op(inflow.ex_ctrl.ALUControl),
        .result(outflow.alu_result),
        .zero(outflow.zero)
    );

    assign outflow.pc_incr = inflow.pc + 32'd4;
    assign outflow.pc_offset = inflow.ex_ctrl.PCOffset ?
    outflow.alu_result : inflow.pc + inflow.immediate; // for jalr

    // forward data
    assign outflow.immediate = inflow.immediate;
    assign outflow.rs2_data = inflow.rs2_data;
    assign outflow.rd_addr = inflow.rd_addr;

    // forward control signals
    assign outflow.mem_ctrl = inflow.mem_ctrl;
    assign outflow.wb_ctrl = inflow.wb_ctrl;
endmodule