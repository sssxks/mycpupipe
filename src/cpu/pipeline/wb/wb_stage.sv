`timescale 1ns/1ps
// `default_nettype none

`include "pipeline_flow_types.sv"

module wb_stage (
    input mem_wb_flow_t inflow,
    output wb_id_backflow_t backflow,

    forwarding_if.wb_stage fd
);
    // pass data back to id stage
    assign backflow.RegWrite = inflow.wb_ctrl.RegWrite;
    assign backflow.rd_addr = inflow.rd_addr;
    always_comb begin
        case (inflow.wb_ctrl.MemtoReg)
            MEMTOREG_ALU: backflow.rd_data = inflow.alu_result;
            MEMTOREG_MEM: backflow.rd_data = inflow.data_in;
            MEMTOREG_PC : backflow.rd_data = inflow.pc_write;
            MEMTOREG_IMM: backflow.rd_data = inflow.immediate;
        endcase
    end

    // pass data to forwarding unit
    assign fd.wb.RegWrite = backflow.RegWrite;
    assign fd.wb.rd_data = backflow.rd_data;
    assign fd.wb.rd_addr = backflow.rd_addr;
endmodule