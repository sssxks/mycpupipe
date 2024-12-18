`timescale 1ns/1ps
// `default_nettype none

module if_stage (
    input  logic            clk,
    input  logic            reset,

    output if_id_flow_t     outflow,
    input  ex_if_backflow_t backflow,

    hazard_if.if_stage hd,
    
    instr_memory_if.user instr_memory_if
);
    pc #(.WIDTH(32)) pc_instance (
        .clk(clk),
        .reset(reset),

        .update_n(hd.Stall),
        .pc_in(backflow.PCSrc ? backflow.pc_offset : outflow.pc + 32'd4),
        .pc_out(outflow.pc)
    );
    
    // communicate with instruction memory
    assign instr_memory_if.pc = outflow.pc;

    // handle flush
    always_comb begin
        if (hd.Flush) begin
            outflow.instr = 32'h00000013; // nop
        end else begin
            outflow.instr = instr_memory_if.instr;
        end
    end
endmodule