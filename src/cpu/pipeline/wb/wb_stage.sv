`timescale 1ns/1ps

module wb_stage (
    input logic [31:0] alu_result,
    input logic [31:0] data_in,
    input logic [31:0] pc_offset,
    input logic [31:0] immediate,

    input logic [31:0] pc_incr,
    input wb_control_t wb_ctrl,
    input logic [4:0] rd_addr_in,

    output logic [4:0] rd_addr_out,
    output logic [31:0] rd_data,
    output logic RegWrite

);
    assign RegWrite = wb_ctrl.RegWrite;
    assign rd_addr_out = rd_addr_in;

    always_comb begin
        case (wb_ctrl.MemtoReg)
            2'd0: rd_data = alu_result;
            2'd1: rd_data = data_in;
            2'd2: rd_data = wb_ctrl.Jump ? pc_incr : pc_offset; // jump=1 -> jalr, jump=0 -> auipc
            2'd3: rd_data = immediate;
        endcase
    end
endmodule