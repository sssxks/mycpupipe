`timescale 1ns/1ps
// `default_nettype none

`include "pipeline_flow_types.sv"

module mem_wb_reg (
    input logic clk,
    input logic reset,

    input mem_wb_flow_t mem_flow,
    output mem_wb_flow_t wb_flow
);
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            wb_flow <= 0;
        end else begin
            wb_flow <= mem_flow;
        end
    end
endmodule