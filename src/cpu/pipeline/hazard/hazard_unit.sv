 `timescale 1ns/1ps
 // `default_nettype none

 module hazard_unit (
    hazard_if.control c
 );
    always_comb begin
        if (c.ex.Load && (c.id.rs1_addr == c.ex.rd_addr || c.id.rs2_addr == c.ex.rd_addr)) begin
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