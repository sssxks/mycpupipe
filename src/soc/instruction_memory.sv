module instruction_memory (
    instr_memory_if.mem instr_mem_if
);
    instruction_memory_impl actual_memory(
        .a(instr_mem_if.pc[11:2]),
        .spo(instr_mem_if.instr)
    );
endmodule