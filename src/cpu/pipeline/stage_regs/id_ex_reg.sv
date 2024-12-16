`timescale 1ns/1ps
`default_nettype none
module id_ex_reg (
    input logic clk,
    input logic reset,

    input id_ex_flow_t id_flow,
    output id_ex_flow_t ex_flow
);
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            ex_flow <= 0;
        end else begin
            ex_flow <= id_flow;
        end
    end
endmodule