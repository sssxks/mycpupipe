`ifndef FORWARDING_TYPES_SV
`define FORWARDING_TYPES_SV

typedef enum logic [1:0] {
    NO_FORWARD = 2'b00,
    FORWARD_MEM = 2'b01,
    FORWARD_WB = 2'b10
} forwarding_t;

typedef struct packed {
    logic RegWrite;
    logic [31:0] alu_result;
    logic [4:0]  rd_addr;
} mem_forwarding_input_t;

typedef struct packed {
    logic RegWrite;
    logic [31:0] rd_data;
    logic [4:0]  rd_addr;
} wb_forwarding_input_t;

typedef struct packed {
    logic [4:0] rs1_addr;
    logic [4:0] rs2_addr;
} ex_forwarding_input_t;

typedef struct packed {
    logic [31:0] mem;
    logic [31:0] wb;
} forwarding_data_output_t;

`endif // FORWARDING_TYPES_SV