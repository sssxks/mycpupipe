`timescale 1ns/1ps
`include "forwarding_types.sv"

interface forwarding_if;
    mem_forwarding_input_t mem;
    wb_forwarding_input_t wb;
    ex_forwarding_input_t ex;

    forwarding_data_output_t data;
    forwarding_t a;
    forwarding_t b;

    modport mem_stage (
        output mem
    );
    
    modport wb_stage (
        output wb
    );

    modport control (
        input ex,
        input mem,
        input wb,

        output data,
        output a,
        output b
    );

    modport ex_stage (
        output ex,

        input data,
        input a,
        input b
    );

endinterface //forwarding_if

