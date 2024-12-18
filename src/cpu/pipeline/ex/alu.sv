`timescale 1ns/1ps
`include "definitions.sv"

// this is behavioral model of ALU
// not very efficient, but easy to maintain
module alu(
    input wire [31:0] a,
    input wire [3:0] op,
    input wire [31:0] b,
    output reg [31:0] result,
    output wire zero
);
    always @(*) begin
        case (op)
            alu_t::ALU_ADD : result = a + b; // ADD
            alu_t::ALU_SUB : result = a - b; // SUB
            alu_t::ALU_SLL : result = a << b[5:0]; // SLL
            alu_t::ALU_SLT : result = ($signed(a) < $signed(b)) 
                                ? 32'b1 : 32'b0; // SLT
            alu_t::ALU_SLTU: result = (a < b) 
                                ? 32'b1 : 32'b0; // SLTU
            alu_t::ALU_XOR : result = a ^ b; // XOR
            alu_t::ALU_SRL : result = a >> b[4:0]; // SRL
            alu_t::ALU_SRA : result = $signed(a) >>> b[4:0]; // SRA
            alu_t::ALU_OR  : result = a | b; // OR
            alu_t::ALU_AND : result = a & b; // AND
            default: result = 32'bx;
        endcase
    end

    assign zero = (result == 32'b0);

endmodule

