`timescale 1ns/1ps

module ex_stage (
    input logic [31:0] pc,
    input logic [31:0] rs1_data,
    input logic [31:0] rs2_data,
    input logic [31:0] immediate,

    input ex_control_t ex_ctrl,

    output logic [31:0] alu_result,
    output logic zero,
    output logic [31:0] pc_incr,
    output logic [31:0] pc_offset
);
    alu alu_instance (
        .a(rs1_data),
        .b(ex_ctrl.ALUSrcB ? immediate : rs2_data),
        .op(ex_ctrl.ALUControl),
        .result(alu_result),
        .zero(zero)
    );

    assign pc_incr = pc + 4;
    assign pc_offset = ex_ctrl.PCOffset ? ALU_out : pc + imm_out; // for jalr

endmodule