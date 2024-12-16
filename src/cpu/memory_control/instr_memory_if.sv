interface instr_memory_if;
    logic [31:0] pc;
    logic [31:0] instr;

    modport user (
        output pc,
        input instr
    );

    modport mem (
        input pc,
        output instr
    );
endinterface //inter_memory_if