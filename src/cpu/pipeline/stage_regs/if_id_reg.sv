`timescale 1ns/1ps
// `default_nettype none

`include "pipeline_flow.sv"

module if_id_reg (
    input logic clk,
    input logic reset,

    input if_id_flow_t if_flow,
    output if_id_flow_t id_flow    
);
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            id_flow <= 0;
        end else begin
            id_flow <= if_flow;
        end
    end
endmodule