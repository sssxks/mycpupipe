`timescale 1ns/1ps
// `default_nettype none

`include "pipeline_flow_types.sv"

module pipeline(
    input logic clk,
    input logic reset,

    instr_memory_if.user instr_mem_if,
    inner_memory_if.user inner_mem_if
);
    // flows
    if_id_flow_t if_flowout, id_flowin;
    id_ex_flow_t id_flowout, ex_flowin;
    ex_mem_flow_t ex_flowout, mem_flowin;
    mem_wb_flow_t mem_flowout, wb_flowin;
    ex_if_backflow_t ex_if_backflow;
    wb_id_backflow_t wb_id_backflow;

    // forwarding interface & unit
    forwarding_if fd();
    forwarding_unit forwarding_instance(
        .c(fd.control)
    );

    // hazard detection interface & unit
    hazard_if hd();
    hazard_unit hazard_instance(
        .c(hd.control)
    );

    if_stage if_stage_instance (
        .clk(clk),
        .reset(reset),
        
        .outflow(if_flowout),
        .backflow(ex_if_backflow),
        .hd(hd.listener),

        .instr_memory_if(instr_mem_if)
    );

    if_id_reg if_id_reg_instance (
        .clk(clk),
        .reset(reset),
        .hd(hd.listener),

        .if_flow(if_flowout),
        .id_flow(id_flowin)
    );

    id_stage id_stage_instance (
        .clk(clk),
        .reset(reset),

        .inflow(id_flowin),
        .outflow(id_flowout),
        .backflow(wb_id_backflow),
        .hd(hd.id_stage)
    );

    id_ex_reg id_ex_reg_instance (
        .clk(clk),
        .reset(reset),
        .hd(hd.listener),

        .id_flow(id_flowout),
        .ex_flow(ex_flowin)
    );

    ex_stage ex_stage_instance (
        .inflow(ex_flowin),
        .outflow(ex_flowout),
        .backflow(ex_if_backflow),
        .fd(fd.ex_stage),
        .hd(hd.ex_stage)
    );

    ex_mem_reg ex_mem_reg_instance (
        .clk(clk),
        .reset(reset),

        .ex_flow(ex_flowout),
        .mem_flow(mem_flowin)
    );

    mem_stage mem_stage_instance (
        .inflow(mem_flowin),
        .outflow(mem_flowout),
        .fd(fd.mem_stage),

        .mem_if(inner_mem_if)
    );

    mem_wb_reg mem_wb_reg_instance (
        .clk(clk),
        .reset(reset),

        .mem_flow(mem_flowout),
        .wb_flow(wb_flowin)
    );

    wb_stage wb_stage_instance (
        .inflow(wb_flowin),
        .backflow(wb_id_backflow),
        .fd(fd.wb_stage)
    );
endmodule