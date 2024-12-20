`include "instruction_types.sv"

module soc_simulation(
    input wire clk,
    input wire reset
);
    instr_memory_if instr_mem_if();
    data_memory_if data_mem_if();

    cpu uut (
        .clk(clk),
        .reset(reset),

        .instr_mem_if(instr_mem_if.user),
        .data_mem_if(data_mem_if.cpu)
    );

    instruction_memory U2(
        .instr_mem_if(instr_mem_if.mem)
    );

    data_memory U3 (
        .clk(clk),
        .mem_if(data_mem_if.mem)
    );
endmodule