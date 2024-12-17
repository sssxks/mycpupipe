`timescale 1ns/1ps
`default_nettype none

module cpu (
    input clk,
    input reset,

    instr_memory_if.user instr_mem_if,
    data_memory_if.cpu data_mem_if
);
    inner_memory_if inner_mem_if_instance();

    pipeline pipeline_instance(
        .clk(clk),
        .reset(reset),

        .instr_mem_if(instr_mem_if),
        .inner_mem_if(inner_mem_if_instance.user)
    );

    memory_handler memory_handler_instance(
        .cpu(inner_mem_if_instance.handler),
        .mem(data_mem_if)
    );
endmodule