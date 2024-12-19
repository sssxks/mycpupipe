`timescale 1ns/1ps
// `default_nettype none

`include "forwarding_types.sv"

module forwarding_unit (
    forwarding_if.control c
);    
    assign c.data.mem = c.mem.alu_result;
    assign c.data.wb = c.wb.rd_data;

    always_comb begin
        // Forwarding for rs1
        if (c.mem.RegWrite && c.mem.rd_addr != 0 && 
            c.mem.rd_addr == c.ex.rs1_addr) begin
            c.a = FORWARD_MEM;
        end else if (c.wb.RegWrite && c.wb.rd_addr != 0 && 
                     c.wb.rd_addr == c.ex.rs1_addr) begin
            c.a = FORWARD_WB;
        end else begin
            c.a = NO_FORWARD;
        end

        // Forwarding for rs2
        if (c.mem.RegWrite && c.mem.rd_addr != 0 && 
            c.mem.rd_addr == c.ex.rs2_addr) begin
            c.b = FORWARD_MEM;
        end else if (c.wb.RegWrite && c.wb.rd_addr != 0 && 
                     c.wb.rd_addr == c.ex.rs2_addr) begin
            c.b = FORWARD_WB;
        end else begin
            c.b = NO_FORWARD;
        end
    end
endmodule