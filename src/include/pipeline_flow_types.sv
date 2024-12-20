`ifndef PIPELINE_FLOW_TYPES_SV
`define PIPELINE_FLOW_TYPES_SV

`include "control_signal_types.sv"
`include "instruction_types.sv"

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
    logic [31:0]  pc_target;
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
    logic PCSrc;  // 1: PC = pc_target (branch taken),
                  // 0: PC = PC + 4 (branch not taken)
    logic [31:0] pc_target;
} ex_if_backflow_t;

// wb -> id backward flow, for writing back to regfile
typedef struct packed {
    logic RegWrite;
    logic [4:0] rd_addr;
    logic [31:0] rd_data;  
} wb_id_backflow_t;

// nop flows, used in initializing(resetting) cpu state
// and when stall/flush happens
const if_id_flow_t NOP_IF_ID_FLOW = '{32'h0, NOP_INSTR};
const id_ex_flow_t NOP_ID_EX_FLOW = '{32'h0, 32'h0, 32'h0, 5'h0, 5'h0, 5'h0, 32'h0, NOP_EX_CTRL, NOP_MEM_CTRL, NOP_WB_CTRL};
const ex_mem_flow_t NOP_EX_MEM_FLOW = '{32'h0, 5'h0, 32'h0, 32'h0, 32'h0, 32'h0, NOP_MEM_CTRL, NOP_WB_CTRL};
const mem_wb_flow_t NOP_MEM_WB_FLOW = '{5'h0, 32'h0, 32'h0, 32'h0, 32'h0, NOP_WB_CTRL};

// endpackage

`endif // PIPELINE_FLOW_TYPES_SV