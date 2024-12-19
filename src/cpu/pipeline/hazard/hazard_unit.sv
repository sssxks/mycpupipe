`timescale 1ns/1ps
 // `default_nettype none

 module hazard_unit (
    hazard_if.control c
 );
    typedef enum logic [0:0] {
        NOT_IN_USE = 1'b0,
        IN_USE = 1'b1
    } in_use_t;

    in_use_t Rs1InUse, Rs2InUse;
    always_comb begin
        if (c.id.rs1_addr != 5'b0 &&
            (c.id.opcode == OPCODE_R_TYPE
            || c.id.opcode == OPCODE_IMMEDIATE_CALCULATION
            || c.id.opcode == OPCODE_LOAD
            || c.id.opcode == OPCODE_S_TYPE
            || c.id.opcode == OPCODE_SB_TYPE)
        ) begin
            Rs1InUse = IN_USE;
        end else begin
            Rs1InUse = NOT_IN_USE;
        end

        if (c.id.rs2_addr != 5'b0 &&
            (c.id.opcode == OPCODE_R_TYPE
            || c.id.opcode == OPCODE_S_TYPE
            || c.id.opcode == OPCODE_SB_TYPE)
        ) begin
            Rs2InUse = IN_USE;
        end else begin
            Rs2InUse = NOT_IN_USE;
        end
    end

    always_comb begin
        if (c.ex.Load && (
            (c.id.rs1_addr == c.ex.rd_addr && Rs1InUse == IN_USE)
            ||
            (c.id.rs2_addr == c.ex.rd_addr && Rs2InUse == IN_USE)
        )) begin
            c.Stall = 1'b1;
        end else begin
            c.Stall = 1'b0;
        end
    end

    always_comb begin
        if (c.ex.PCSrc) begin
            c.Flush = 1'b1;
        end else begin
            c.Flush = 1'b0;
        end
    end
 endmodule