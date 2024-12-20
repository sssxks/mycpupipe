`timescale 1ns/1ps
// `default_nettype none

`include "pipeline_flow_types.sv"

module mem_stage (
    input ex_mem_flow_t inflow,
    output mem_wb_flow_t outflow,

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
    // jump=1 -> jalr, jump=0 -> auipc
    assign outflow.pc_write = inflow.mem_ctrl.Jump ? inflow.pc_incr : inflow.pc_target; 
    
    // pass rest of data
    assign outflow.immediate = inflow.immediate;
    assign outflow.alu_result = inflow.alu_result;
    assign outflow.rd_addr = inflow.rd_addr;
    // pass rest of control signals
    assign outflow.wb_ctrl = inflow.wb_ctrl;

    // pass data to forwarding unit
    assign fd.mem.alu_result = inflow.alu_result;
    assign fd.mem.RegWrite = inflow.wb_ctrl.RegWrite;
    assign fd.mem.rd_addr = inflow.rd_addr;
endmodule