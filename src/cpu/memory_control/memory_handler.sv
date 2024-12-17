`timescale 1ns/1ps
`include "definitions.sv"

// providing half, byte length and sign extension
module memory_handler (
    inner_memory_if.handler cpu,
    data_memory_if.cpu mem
);
    assign mem.addr_out = {cpu.addr_out[11:2]}; // Align address to 4 bytes
    wire [1:0] where = cpu.addr_out[1:0]; // word offset

    always_comb begin
        if (cpu.MemRW == 1'b0) begin // read
            case (cpu.RWType)
                `BYTE: cpu.data_in = {
                    {24{mem.data_in[{where, 3'b0}]}},
                    mem.data_in[{where, 3'b0} +: 8]
                };
                `BYTE_U: cpu.data_in = {
                    24'b0,
                    mem.data_in[{where, 3'b0} +: 8]
                };
                `HALF: cpu.data_in = {
                    {16{mem.data_in[{where[1], 4'b0}]}},
                    mem.data_in[{where[1], 4'b0} +: 16]
                };
                `HALF_U: cpu.data_in = {
                    16'b0, 
                    mem.data_in[{where[1], 4'b0} +: 16]
                };
                `WORD: cpu.data_in = mem.data_in;
                default: cpu.data_in = 32'bx;
            endcase
            mem.data_out = 32'b0;
            mem.WriteEnable = 4'b0;
        end else begin // write
            case (cpu.RWType)
                `BYTE: begin // sb
                    mem.data_out = {4{cpu.data_out[7:0]}};
                    mem.WriteEnable = 4'b0001 << where;
                end
                `HALF: begin // sh
                    mem.data_out = {2{cpu.data_out[15:0]}};
                    mem.WriteEnable = 4'b0011 << where;
                end
                `WORD: begin // sw
                    mem.data_out = cpu.data_out;
                    mem.WriteEnable = 4'b1111;
                end
                default: begin
                    mem.data_out = 32'bx;
                    mem.WriteEnable = 4'b0;
                end
            endcase
            cpu.data_in = 32'b0;
        end
    end
endmodule