`ifndef PIPELINE_FLOW_SV
`define PIPELINE_FLOW_SV

`include "control_signals.sv"

// package pipeline_flow;

typedef struct packed{
    logic [31:0]  pc;
    logic [31:0]  instr;
} if_id_flow_t;

typedef struct packed{
    logic [31:0]  pc;
    logic [31:0]  rs1_data;
    logic [31:0]  rs2_data;
    logic [4:0]   rs1_addr; // added for forwarding
    logic [4:0]   rs2_addr; // added for forwarding
    logic [4:0]   rd_addr;
    logic [31:0]  immediate;

    ex_control_t  ex_ctrl;
    mem_control_t mem_ctrl;
    wb_control_t  wb_ctrl;
} id_ex_flow_t;

typedef struct packed{
    logic [31:0]  rs2_data;
    logic [4:0]   rd_addr;
    logic [31:0]  pc_incr;
    logic [31:0]  pc_offset;
    logic [31:0]  alu_result;
    logic [31:0]  immediate;

    mem_control_t mem_ctrl;
    wb_control_t  wb_ctrl;
} ex_mem_flow_t;

typedef struct packed{
    logic [4:0]   rd_addr;
    logic [31:0]  alu_result;
    logic [31:0]  data_in;
    logic [31:0]  pc_write;
    logic [31:0]  immediate;
    
    wb_control_t  wb_ctrl;
} mem_wb_flow_t;

// ex -> if backward flow, for branching
typedef struct packed {
    logic PCSrc;  // 1: PC = pc_offset (branch taken),
                  // 0: PC = PC + 4 (branch not taken)
    logic [31:0] pc_offset;
} ex_if_backflow_t;

// wb -> id backward flow, for writing back to regfile
typedef struct packed {
    logic RegWrite;
    logic [4:0] rd_addr;
    logic [31:0] rd_data;  
} wb_id_backflow_t;

// endpackage

`endif // PIPELINE_FLOW_SV