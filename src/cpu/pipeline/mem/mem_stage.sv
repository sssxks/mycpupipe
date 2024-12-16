`timescale 1ns/1ps

module mem_stage (
    input ex_mem_flow_t inflow,
    output mem_wb_flow_t outflow,

    // back to IF
    output logic PCSrc,
    output logic [31:0] pc_offset,

    inner_memory_if.user mem_if
);
    assign mem_if.addr_out = inflow.alu_result;
    assign mem_if.MemRW = inflow.mem_ctrl.MemRW;
    assign mem_if.RWType = inflow.mem_ctrl.RWType;
    assign mem_if.data_out = inflow.rs2_data;

    assign outflow.data_in = mem_if.data_in;
    assign outflow.pc_incr = inflow.pc_incr;

    assign pc_offset = inflow.pc_offset;

    assign outflow.immediate = inflow.immediate;
    assign outflow.rd_addr = inflow.rd_addr;
    assign outflow.wb_ctrl = inflow.wb_ctrl;
    assign outflow.alu_result = inflow.alu_result;

    // assign PCSrc = mem_ctrl.Jump || (mem_ctrl.Branch && (mem_ctrl.InverseBranch ? ~zero : zero));
    // simplifies to
    assign PCSrc = inflow.mem_ctrl.Jump || (inflow.mem_ctrl.Branch ^ inflow.zero);
endmodule