interface data_memory_if;
    logic [31:0] Data_in; // Data input from memory
    logic [3:0] MemWriteEnable;// Memory read/write signal
    logic [31:0] Addr_out; // Address output to memory, should be aligned to 4 bytes
    logic [31:0] Data_out; // Data output to memory

    modport mem (
    input MemWriteEnable, 
    input Addr_out,
    input Data_out,
    output Data_in
    );

    modport cpu (
    output MemWriteEnable,
    output Addr_out,
    output Data_out,
    input Data_in
    );
endinterface //data_memory_if