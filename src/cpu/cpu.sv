`timescale 1ns/1ps
`default_nettype none
`include "pipeline_flow.sv"

module cpu (
    input logic clk,
    input logic reset,

    data_memory_if.cpu mem_if,
    instr_memory_if.user instr_mem_if
);
    if_id_flow_t if_flowout;
    if_id_flow_t id_flowin;
    id_ex_flow_t id_flowout;
    id_ex_flow_t ex_flowin;
    ex_mem_flow_t ex_flowout;
    ex_mem_flow_t mem_flowin;
    mem_wb_flow_t mem_flowout;
    mem_wb_flow_t wb_flowin;

    inner_memory_if inner_memory_if_instance();

    logic PCSrc;
    if_stage if_stage_instance (
        .clk(clk),
        .reset(reset),
        .enable(1'b1),
        
        .outflow(if_flowout),

        .PCSrc(PCSrc),
        .pc_offset(pc_offset),
        .pc_incr(pc_incr),

        .instr_memory_if(instr_mem_if)
    );

    if_id_reg if_id_reg_instance (
        .clk(clk),
        .reset(reset),

        .if_flow(if_flowout),
        .id_flow(id_flowin)
    );

    id_stage id_stage_instance (
        .clk(clk),
        .reset(reset),

        .inflow(id_flowin),
        .outflow(id_flowout),

        .RegWriteIn(RegWriteIn),
        .rd_addr(rd_addr),
        .rd_data(rd_data)
    );

    id_ex_reg id_ex_reg_instance (
        .clk(clk),
        .reset(reset),

        .id_flow(id_flowout),
        .ex_flow(ex_flowin)
    );

    ex_stage ex_stage_instance (
        .inflow(ex_flowin),
        .outflow(ex_flowout)
    );

    ex_mem_reg ex_mem_reg_instance (
        .clk(clk),
        .reset(reset),

        .ex_flow(ex_flowout),
        .mem_flow(mem_flowin)
    );

    mem_stage mem_stage_instance (
        .mem_if(inner_memory_if_instance.user)
    );

    mem_wb_reg mem_wb_reg_instance (
        .clk(clk),
        .reset(reset)
    );

    wb_stage wb_stage_instance (
        .clk(clk),
        .reset(reset)

    );
    
endmodule