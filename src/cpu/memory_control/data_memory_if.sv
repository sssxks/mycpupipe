interface data_memory_if;
    logic [3:0] WriteEnable;// Memory read/write signal
    logic [11:2] addr_out; // Address output to memory, should be aligned to 4 bytes
    logic [31:0] data_in; // Data input from memory
    logic [31:0] data_out; // Data output to memory

    modport cpu (
        output WriteEnable,
        output addr_out,
        output data_out,
        input data_in
    );

    modport mem (
        input WriteEnable, 
        input addr_out,
        input data_out,
        output data_in
    );
endinterface //data_memory_if