`timescale 1ns/1ps

module mem_stage (
    input ex_mem_flow_t inflow,

    output logic PCSrc,
    output logic [31:0] pc_incr,
    output logic [31:0] data_in,

    // back to IF
    output logic [31:0] pc_offset,

    inner_memory_if.user mem_if
);
    assign mem_if.addr_out = inflow.alu_result;
    assign mem_if.MemRW = inflow.mem_ctrl.MemRW;
    assign mem_if.RWType =inflow.mem_ctrl.RWType;

    assign data_in = mem_if.data_in;
    assign pc_incr = inflow.pc_incr;

    assign pc_offset = inflow.pc_offset;

    assign wb_ctrl = inflow.wb_ctrl;

    // assign PCSrc = mem_ctrl.Jump || (mem_ctrl.Branch && (mem_ctrl.InverseBranch ? ~zero : zero));
    // simplifies to
    assign PCSrc = inflow.mem_ctrl.Jump || (inflow.mem_ctrl.Branch ^ inflow.zero);
endmodule