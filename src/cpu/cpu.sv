`timescale 1ns/1ps
`default_nettype none

`include "control_signals.sv"

module cpu (
    input logic clk,
    input logic reset,

    input logic [31:0] instr,
    output logic pc,

    data_memory_if.cpu mem_if
);
    logic [31:0] if_pc;
    logic PCSrc;
    logic [31:0] pc_in;
    if_stage if_stage_instance (
        .clk(clk),
        .reset(reset),
        .enable(1'b1),
        
        .pc_out(if_pc),

        .pc_in(pc_in),
        .PCSrc(PCSrc)
    );

    // pass pc to instruction memory & retrieve instr
    assign pc = if_pc;

    if_id_reg if_id_reg_instance (
        .clk(clk),
        .reset(reset),

        .if_pc(if_pc),
        .if_instruction(instr),

        .id_pc(id_pc),
        .id_instruction(id_instr)
    );

    ex_control_t id_ex_ctrl;
    mem_control_t id_mem_ctrl;
    wb_control_t id_wb_ctrl;
    id_stage id_stage_instance (
        .clk(clk),
        .reset(reset),

        .RegWriteIn(RegWriteIn),
        .rd_addr_in(rd_addr_in),
        .rd_data(rd_data),
        .instr(instr),
        .rs1_data(rs1_data),
        .rs2_data(rs2_data),
        .rd_addr_out(rd_addr_out),
        .immediate(immediate),

        .ex_ctrl(ex_ctrl_id2if),
        .mem_ctrl(mem_ctrl_id2if),
        .wb_ctrl(wb_ctrl_id2if)
    );

    id_ex_reg id_ex_reg_instance (
        .clk(clk),
        .reset(reset),

        .id_ex_ctrl(id_ex_ctrl),
        .id_mem_ctrl(id_mem_ctrl),
        .id_wb_ctrl(id_wb_ctrlf)
    );

    ex_stage ex_stage_instance (

    );

    ex_mem_reg ex_mem_reg_instance (

    );

    mem_stage mem_stage_instance (
    );

    mem_wb_reg mem_wb_reg_instance (
        .clk(clk),
        .reset(reset),

    );

    wb_stage wb_stage_instance (
        .clk(clk),
        .reset(reset),

    );
    
endmodule