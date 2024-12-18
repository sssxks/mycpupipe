`timescale 1ns/1ps
`default_nettype none

module if_stage (
    input  logic        clk,
    input  logic        reset,

    output if_id_flow_t outflow,

    input  logic [31:0] pc_offset,
    input  logic        PCSrc,

    hazard_if.if_stage hd,
    
    instr_memory_if.user instr_memory_if
);
    pc #(.WIDTH(32)) pc_instance (
        .clk(clk),
        .reset(reset),

        .update_n(hd.Stall),
        .pc_in(PCSrc ? pc_offset : outflow.pc + 32'd4),
        .pc_out(outflow.pc)
    );
    
    // communicate with instruction memory
    assign instr_memory_if.pc = outflow.pc;
    assign outflow.instr = instr_memory_if.instr;
endmodule