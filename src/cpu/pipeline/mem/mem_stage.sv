`timescale 1ns/1ps
`default_nettype none

`include "pipeline_flow.sv"

module mem_stage (
    input ex_mem_flow_t inflow,
    output mem_wb_flow_t outflow,

    // back to IF
    output logic PCSrc,
    output logic [31:0] pc_offset,

    forwarding_if.mem_stage fd,

    inner_memory_if.user mem_if
);
    // communicate with data memory
    assign mem_if.addr_out = inflow.alu_result;
    assign mem_if.MemRW = inflow.mem_ctrl.MemRW;
    assign mem_if.RWType = inflow.mem_ctrl.RWType;
    assign mem_if.data_out = inflow.rs2_data;
    assign outflow.data_in = mem_if.data_in;

    // decide which pc next to write to register
    assign outflow.pc_write = inflow.mem_ctrl.Jump ? inflow.pc_incr : inflow.pc_offset; // jump=1 -> jalr, jump=0 -> auipc
    // forward data
    assign outflow.immediate = inflow.immediate;
    assign outflow.alu_result = inflow.alu_result;
    assign outflow.rd_addr = inflow.rd_addr;
    // forward control
    assign outflow.wb_ctrl = inflow.wb_ctrl;

    assign pc_offset = inflow.pc_offset;
    // assign PCSrc = mem_ctrl.Jump || (mem_ctrl.Branch && (mem_ctrl.InverseBranch ? ~zero : zero));
    // simplifies to
    assign PCSrc = inflow.mem_ctrl.Jump || (inflow.mem_ctrl.Branch & (inflow.mem_ctrl.InverseBranch ^ inflow.zero));

    // forwarding
    assign fd.mem.alu_result = inflow.alu_result;
    assign fd.mem.rd_addr = inflow.rd_addr;
    assign fd.mem.RegWrite = inflow.wb_ctrl.RegWrite;
endmodule