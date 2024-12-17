`timescale 1ns/1ps
`default_nettype none

`include "pipeline_flow.sv"

module wb_stage (
    input mem_wb_flow_t inflow,

    // back to ID
    output logic [4:0] rd_addr,
    output logic [31:0] rd_data,
    output logic RegWrite
);
    assign RegWrite = inflow.wb_ctrl.RegWrite;
    assign rd_addr = inflow.rd_addr;

    always_comb begin
        case (inflow.wb_ctrl.MemtoReg)
            2'd0: rd_data = inflow.alu_result;
            2'd1: rd_data = inflow.data_in;
            2'd2: rd_data = inflow.pc_write;
            2'd3: rd_data = inflow.immediate;
        endcase
    end
endmodule