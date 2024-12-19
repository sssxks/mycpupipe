`timescale 1ns/1ps
// `default_nettype none

`include "pipeline_flow_types.sv"

module id_ex_reg (
    input logic clk,
    input logic reset,
    hazard_if.listener hd,

    input id_ex_flow_t id_flow,
    output id_ex_flow_t ex_flow
);
    always_ff @(posedge clk or posedge reset) begin
        // if we need to stall or flush, discard the current flow
        // use do-nothing flow instead
        if (reset || hd.Stall || hd.Flush) begin
            ex_flow <= NOP_ID_EX_FLOW;
        end else begin
            ex_flow <= id_flow;
        end
    end
endmodule