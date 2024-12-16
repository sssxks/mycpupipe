interface instr_memory_if;
    logic [31:0] instr;
    logic [31:0] pc;

    modport user (
        input instr,
        output pc
    );

    modport memory (
        output instr,
        input pc
    );
endinterface //inter_memory_if