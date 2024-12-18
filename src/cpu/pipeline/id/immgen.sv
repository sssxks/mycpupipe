`timescale 1ns/1ps
// `default_nettype none

`include "instruction_types.sv"

module immgen(
    input wire immgen_t ImmSel,
    input wire [31:7] instr,
    output reg [31:0] immediate
);
    always_comb begin
        case(ImmSel)
            immgen_t::IMMGEN_I: immediate = {{20{instr[31]}}, instr[31:20]};
            immgen_t::IMMGEN_S: immediate = {{20{instr[31]}}, instr[31:25], instr[11:7]};
            immgen_t::IMMGEN_SB: immediate = {{19{instr[31]}}, instr[31], instr[7], instr[30:25], instr[11:8], 1'b0};
            immgen_t::IMMGEN_UJ: immediate = {{11{instr[31]}}, instr[31], instr[19:12], instr[20], instr[30:21], 1'b0};
            immgen_t::IMMGEN_U: immediate = {instr[31:12], 12'b0};
            default: immediate = 32'bx;
        endcase
    end
endmodule