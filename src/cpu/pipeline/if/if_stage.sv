`timescale 1ns/1ps

module if_stage (
    input  logic        clk,
    input  logic        reset,
    input  logic        enable,

    output if_id_flow_t outflow,

    input  logic [31:0] pc_offset,
    input  logic [31:0] pc_incr,
    input  logic        PCSrc,
    
    instr_memory_if.user instr_memory_if
);
    logic [31:0] pc_curr;
    
    pc #(.WIDTH(32)) pc_instance (
        .clk(clk),
        .reset(reset),

        .pc_in(PCSrc ? pc_offset : pc_incr),
        .pc_out(pc_curr)
    );
    
    assign outflow.pc = pc_curr;
    assign instr_memory_if.pc = pc_curr;
    assign outflow.instr = instr_memory_if.instr;
endmodule