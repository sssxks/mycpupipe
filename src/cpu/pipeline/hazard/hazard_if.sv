`timescale 1ns/1ps
`default_nettype none

typedef struct packed {
    logic Load;
    logic [4:0] rd_addr;
} ex_hazard_input_t;

typedef struct packed {
    logic [4:0] rs1_addr;
    logic [4:0] rs2_addr;
} id_hazard_input_t;

interface hazard_if;
    id_hazard_input_t id;
    ex_hazard_input_t ex;

    logic Stall;

    modport ex_stage (
        output ex
    );

    modport id_stage (
        output id,
        input Stall
    );

    modport control (
        input id,
        input ex,

        output Stall
    );

    modport if_stage (
        input Stall
    );

endinterface //hazard_if