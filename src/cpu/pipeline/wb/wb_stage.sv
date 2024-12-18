`timescale 1ns/1ps
// `default_nettype none

`include "pipeline_flow.sv"

module wb_stage (
    input mem_wb_flow_t inflow,
    output wb_id_backflow_t backflow,

    forwarding_if.wb_stage fd
);
    assign backflow.RegWrite = inflow.wb_ctrl.RegWrite;
    assign backflow.rd_addr = inflow.rd_addr;

    always_comb begin
        case (inflow.wb_ctrl.MemtoReg)
            2'd0: backflow.rd_data = inflow.alu_result;
            2'd1: backflow.rd_data = inflow.data_in;
            2'd2: backflow.rd_data = inflow.pc_write;
            2'd3: backflow.rd_data = inflow.immediate;
        endcase
    end

    // forwarding
    assign fd.wb.RegWrite = backflow.RegWrite;
    assign fd.wb.rd_data = backflow.rd_data;
    assign fd.wb.rd_addr = backflow.rd_addr;
endmodule