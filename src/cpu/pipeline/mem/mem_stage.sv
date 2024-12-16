`timescale 1ns/1ps

module mem_stage (
    input  logic zero,
    input  logic [31:0] alu_result,
    input  logic [31:0] rs2_data,
    input  logic [31:0] pc_incr_in,
    input  logic [31:0] pc_offset,

    input  mem_control_t mem_ctrl,

    output logic PCSrc,
    output logic [31:0] pc_incr_out,
    output logic [31:0] data_in,

    // back to IF
    output logic [31:0] pc_offset,

    inner_memory_if.user mem_if
);
    assign mem_if.addr_out = alu_result;
    assign mem_if.MemRW = mem_ctrl.MemRW;
    assign mem_if.RWType = mem_ctrl.RWType;
    assign data_in = mem_if.data_in;
    assign pc_incr_out = pc_incr_in;

    // assign PCSrc = mem_ctrl.Jump || (mem_ctrl.Branch && (mem_ctrl.InverseBranch ? ~zero : zero));
    assign PCSrc = mem_ctrl.Jump || (mem_ctrl.Branch ^ zero);
endmodule