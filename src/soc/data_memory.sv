module data_memory (
    input logic clk,
    data_memory_if.mem mem_if
);
    data_memory_impl actual_memory(
        .clka(~clk), 
        .wea(mem_if.WriteEnable), 
        .addra(mem_if.addr_out[11:2]),
        .dina(mem_if.data_out), 
        .douta(mem_if.data_in) 
    );
endmodule