`timescale 1ns/1ps
// `default_nettype none

`include "pipeline_flow_types.sv"

module if_id_reg (
    input logic clk,
    input logic reset,
    hazard_if.listener hd,

    input if_id_flow_t if_flow,
    output if_id_flow_t id_flow    
);

    always_ff @(posedge clk or posedge reset) begin
        // if we need to flush, discard the instruction just fetched
        if (reset || hd.Flush) begin
            id_flow <= NOP_IF_ID_FLOW;
        // if we are stalled, retain the current state
        end else if (hd.Stall) begin
            id_flow <= id_flow;
        // if we are not stalled, pass the instruction to next stage
        end else begin
            id_flow <= if_flow;
        end
    end
endmodule