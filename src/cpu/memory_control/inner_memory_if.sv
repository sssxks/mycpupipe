interface inner_memory_if;
    logic MemRW;
    logic RWType;
    logic [31:0] addr_out;
    logic [31:0] data_out;
    logic [31:0] data_in;

    modport user(
        output MemRW,
        output RWType,
        output addr_out,
        output data_out,
        input data_in
    );

    modport controller(
        input MemRW,
        input RWType,
        input addr_out,
        input data_out,
        output data_in
    );
endinterface //inner_memory_if