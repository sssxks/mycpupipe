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
            `ALU_ADD : result = a + b; // ADD
            `ALU_SUB : result = a - b; // SUB
            `ALU_SLL : result = a << b[5:0]; // SLL
            `ALU_SLT : result = ($signed(a) < $signed(b)) 
                                ? 32'b1 : 32'b0; // SLT
            `ALU_SLTU: result = (a < b) 
                                ? 32'b1 : 32'b0; // SLTU
            `ALU_XOR : result = a ^ b; // XOR
            `ALU_SRL : result = a >> b[4:0]; // SRL
            `ALU_SRA : result = $signed(a) >>> b[4:0]; // SRA
            `ALU_OR  : result = a | b; // OR
            `ALU_AND : result = a & b; // AND
            default: result = 32'bx;
        endcase
    end

    assign zero = (result == 32'b0);

endmodule

