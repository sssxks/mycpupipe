interface data_memory_if;
    logic [3:0] MemWriteEnable;// Memory read/write signal
    logic [31:0] data_in; // Data input from memory
    logic [31:0] addr_out; // Address output to memory, should be aligned to 4 bytes
    logic [31:0] data_out; // Data output to memory

    modport mem (
    input MemWriteEnable, 
    input addr_out,
    input data_out,
    output data_in
    );

    modport cpu (
    output MemWriteEnable,
    output addr_out,
    output data_out,
    input data_in
    );
endinterface //data_memory_if