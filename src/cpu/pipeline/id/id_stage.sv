`timescale 1ns / 1ps
`default_nettype none
`include "definitions.sv"

module regs(
    input wire clk, rst, RegWrite,
    input wire [4:0] Rs1_addr, Rs2_addr, Wt_addr,
    input wire [31:0] Wt_data,
    output wire [31:0] Rs1_data, Rs2_data
);
    reg [31:0] register [1:31]; // x1 - x31, x0 is hard wired to 0
    
    assign Rs1_data = (Rs1_addr == 0) ? 0 : register[Rs1_addr];
    assign Rs2_data = (Rs2_addr == 0) ? 0 : register[Rs2_addr];

    integer i;
    always @(posedge clk or posedge rst) begin
        if (rst == 1) begin
            for (i = 1; i < 32; i = i + 1)
                register[i] <= 0; // reset
        end else if ((Wt_addr != 0) && (RegWrite == 1))
            register[Wt_addr] <= Wt_data; // write
    end
endmodule

module immgen(
    input wire [2:0] ImmSel,
    input wire [31:0] instr, // raw instruction
    output reg [31:0] imm_out
);
    always @(*) begin
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

module id_stage (
    
);
    
endmodule