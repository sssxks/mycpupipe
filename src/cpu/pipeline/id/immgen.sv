`timescale 1ns/1ps
`include "definitions.sv"

module immgen(
    input wire [2:0] ImmSel,
    input wire [31:0] instr, // raw instructiond
    output reg [31:0] imm_out
);
    always_comb begin
        case(ImmSel)
            `IMMGEN_I:imm_out = {{20{instr[31]}},instr[31:20]};
            `IMMGEN_S:imm_out = {{20{instr[31]}}, instr[31:25], instr[11:7]};
            `IMMGEN_SB:imm_out = {{19{instr[31]}}, instr[31], instr[7], instr[30:25], instr[11:8], 1'b0};
            `IMMGEN_UJ:imm_out = {{11{instr[31]}}, instr[31], instr[19:12], instr[20], instr[30:21], 1'b0};
            `IMMGEN_U:imm_out = {instr[31:12], 12'b0};
            default: imm_out = 32'bx;
        endcase
    end
endmodule