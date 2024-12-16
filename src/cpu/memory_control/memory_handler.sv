`timescale 1ns/1ps
`include "definitions.sv"

// providing endianess and sign extension
module memory_handler (
    inner_memory_if.handler cpu,
    data_memory_if.cpu mem
);
    assign mem.addr_out = {cpu.addr_out[31:2], 2'b00}; // Align address to 4 bytes
    wire [1:0] where = cpu.addr_out[1:0]; // word offset

    always @(*) begin
        if (cpu.MemRW == 1'b0) begin // read
            case (cpu.RWType)
                `BYTE: begin
                    case (where)
                        2'b00: cpu.data_in = {{24{mem.data_in[7]}}, mem.data_in[7:0]};
                        2'b01: cpu.data_in = {{24{mem.data_in[15]}}, mem.data_in[15:8]};
                        2'b10: cpu.data_in = {{24{mem.data_in[23]}}, mem.data_in[23:16]};
                        2'b11: cpu.data_in = {{24{mem.data_in[31]}}, mem.data_in[31:24]};
                    endcase
                end
                `BYTE_U: begin
                    case (where)
                        2'b00: cpu.data_in = {24'b0, mem.data_in[7:0]};
                        2'b01: cpu.data_in = {24'b0, mem.data_in[15:8]};
                        2'b10: cpu.data_in = {24'b0, mem.data_in[23:16]};
                        2'b11: cpu.data_in = {24'b0, mem.data_in[31:24]};
                    endcase
                end
                `HALF: begin
                    case (where[1])
                        1'b0: cpu.data_in = {{16{mem.data_in[15]}}, mem.data_in[15:0]};
                        1'b1: cpu.data_in = {{16{mem.data_in[31]}}, mem.data_in[31:16]};
                    endcase
                end
                `HALF_U: begin
                    case (where[1])
                        1'b0: cpu.data_in = {16'b0, mem.data_in[15:0]};
                        1'b1: cpu.data_in = {16'b0, mem.data_in[31:16]};
                    endcase
                end
                `WORD: cpu.data_in = mem.data_in;
                default: cpu.data_in = 32'bx;
            endcase
            mem.data_out = 32'b0;
            mem.MemWriteEnable = 4'b0;
        end else begin // write
            case (cpu.RWType)
                `BYTE: begin // sb
                    mem.data_out = {4{cpu.data_out[7:0]}};
                    mem.MemWriteEnable = 4'b0001 << where;
                end
                `HALF: begin // sh
                    mem.data_out = {2{cpu.data_out[15:0]}};
                    mem.MemWriteEnable = 4'b0011 << where;
                end
                `WORD: begin // sw
                    mem.data_out = cpu.data_out;
                    mem.MemWriteEnable = 4'b1111;
                end
                default: begin
                    mem.data_out = 32'bx;
                    mem.MemWriteEnable = 4'b0;
                end
            endcase
            cpu.data_in = 32'b0;
        end
    end
endmodule