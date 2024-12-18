`timescale 1ns/1ps
// `default_nettype none
`include "pipeline_flow.sv"
`include "forwarding_types.sv"

module ex_stage (
    input id_ex_flow_t inflow,
    output ex_mem_flow_t outflow,
    output ex_if_backflow_t backflow,

    forwarding_if.ex_stage fd,
    hazard_if.ex_stage hd
);
    assign fd.ex.rs1_addr = inflow.rs1_addr;
    assign fd.ex.rs2_addr = inflow.rs2_addr;
    
    logic [31:0] a, b;
    always_comb begin
        case (fd.a)
            forwarding_t::FORWARD_MEM: a = fd.data.mem;
            forwarding_t::FORWARD_WB: a = fd.data.wb;
            default: a = inflow.rs1_data;
        endcase
        case (fd.b)
            forwarding_t::FORWARD_MEM: b = fd.data.mem;
            forwarding_t::FORWARD_WB: b = fd.data.wb;
            default: b = inflow.ex_ctrl.ALUSrcB ?
           inflow.immediate : inflow.rs2_data;
        endcase
    end

    assign hd.ex.Load = inflow.wb_ctrl.MemtoReg == 2'd1;
    assign hd.ex.PCSrc = backflow.PCSrc;
    assign hd.ex.rd_addr = inflow.rd_addr;

    logic zero;
    alu alu_instance (
        .a(a),
        .b(b),
        .op(inflow.ex_ctrl.ALUControl),
        .result(outflow.alu_result),
        .zero(zero)
    );

    assign backflow.pc_offset = inflow.ex_ctrl.PCOffset ?
    outflow.alu_result : inflow.pc + inflow.immediate; // for jalr
    // assign PCSrc = mem_ctrl.Jump || (mem_ctrl.Branch && (mem_ctrl.InverseBranch ? ~zero : zero));
    // simplifies to
    assign backflow.PCSrc = inflow.mem_ctrl.Jump || (inflow.ex_ctrl.Branch & (inflow.ex_ctrl.InverseBranch ^ zero));

    assign outflow.pc_incr = inflow.pc + 32'd4;
    assign outflow.pc_offset = backflow.pc_offset;

    // forward data
    assign outflow.immediate = inflow.immediate;
    assign outflow.rs2_data = inflow.rs2_data;
    assign outflow.rd_addr = inflow.rd_addr;
    // forward control
    assign outflow.mem_ctrl = inflow.mem_ctrl;
    assign outflow.wb_ctrl = inflow.wb_ctrl;
endmodule