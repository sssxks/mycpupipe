`timescale 1ns/1ps
// `default_nettype none
`include "pipeline_flow_types.sv"
`include "forwarding_types.sv"

module ex_stage (
    input id_ex_flow_t inflow,
    output ex_mem_flow_t outflow,
    output ex_if_backflow_t backflow,

    forwarding_if.ex_stage fd,
    hazard_if.ex_stage hd
);
    // tell forwarding unit which register used
    assign fd.ex.rs1_addr = inflow.rs1_addr;
    assign fd.ex.rs2_addr = inflow.rs2_addr;
    
    // forwarding unit gives us fresh data
    logic [31:0] fd_rs1_data, fd_rs2_data;
    always_comb begin
        case (fd.rs1)
            FORWARD_MEM: fd_rs1_data = fd.data.mem;
            FORWARD_WB: fd_rs1_data = fd.data.wb;
            default: fd_rs1_data = inflow.rs1_data;
        endcase

        case (fd.rs2)
            FORWARD_MEM: fd_rs2_data = fd.data.mem;
            FORWARD_WB: fd_rs2_data = fd.data.wb;
            default: fd_rs2_data = inflow.rs2_data;
        endcase
    end

    // feed the data to ALU, result passed to next stage
    logic zero;
    alu alu_instance (
        .a(fd_rs1_data),
        .b(inflow.ex_ctrl.ALUSrcB ? inflow.immediate : fd_rs2_data),
        .op(inflow.ex_ctrl.ALUControl),
        .result(outflow.alu_result),
        .zero(zero)
    );
    // feed the data to memory stage
    assign outflow.rs2_data = fd_rs2_data;

    // now we works on branching, first pass branched PC and signal back to if
    assign backflow.pc_offset = inflow.ex_ctrl.PCOffset ?
        outflow.alu_result : inflow.pc + inflow.immediate; // for jalr
    assign backflow.PCSrc = inflow.mem_ctrl.Jump || 
        (inflow.ex_ctrl.Branch & (inflow.ex_ctrl.InverseBranch ^ zero));

    // hazard detection unit needs these signals
    assign hd.ex.Load = inflow.wb_ctrl.RegWrite // if we are about to load
        && inflow.wb_ctrl.MemtoReg == MEMTOREG_MEM; 
    assign hd.ex.rd_addr = inflow.rd_addr;
    assign hd.ex.PCSrc = backflow.PCSrc; // if we are about to jump

    // then pass pc calculation result to next stage
    assign outflow.pc_incr = inflow.pc + 32'd4;
    assign outflow.pc_offset = backflow.pc_offset;

    // pass rest of data
    assign outflow.immediate = inflow.immediate;
    assign outflow.rd_addr = inflow.rd_addr;
    // pass rest of control signals
    assign outflow.mem_ctrl = inflow.mem_ctrl;
    assign outflow.wb_ctrl = inflow.wb_ctrl;
endmodule