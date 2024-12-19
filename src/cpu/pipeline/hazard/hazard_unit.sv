 `timescale 1ns/1ps
 // `default_nettype none

 module hazard_unit (
    hazard_if.control c
 );
    logic rs1_inuse, rs2_inuse;
    always_comb begin
        if (c.id.rs1_addr != 5'b0 &&
            (c.id.opcode == OPCODE_R_TYPE
            || c.id.opcode == OPCODE_IMMEDIATE_CALCULATION
            || c.id.opcode == OPCODE_LOAD
            || c.id.opcode == OPCODE_S_TYPE
            || c.id.opcode == OPCODE_SB_TYPE)
        ) begin
            rs1_inuse = 1'b1;
        end else begin
            rs1_inuse = 1'b0;
        end

        if (c.id.rs2_addr != 5'b0 &&
            (c.id.opcode == OPCODE_R_TYPE
            || c.id.opcode == OPCODE_S_TYPE
            || c.id.opcode == OPCODE_SB_TYPE)
        ) begin
            rs2_inuse = 1'b1;
        end else begin
            rs2_inuse = 1'b0;
        end
    end

    always_comb begin
        if (c.ex.Load && (
            (c.id.rs1_addr == c.ex.rd_addr && rs1_inuse)
            ||
            (c.id.rs2_addr == c.ex.rd_addr && rs2_inuse)
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