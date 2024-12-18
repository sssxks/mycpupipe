`timescale 1ns/1ps
// `default_nettype none

`include "pipeline_flow.sv"

module ex_mem_reg (
    input logic clk,
    input logic reset,

    input ex_mem_flow_t ex_flow,
    output ex_mem_flow_t mem_flow
);
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            mem_flow <= 0;
        end else begin
            mem_flow <= ex_flow;
        end
    end
endmodule