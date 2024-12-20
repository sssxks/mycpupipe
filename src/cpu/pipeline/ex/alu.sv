`timescale 1ns/1ps
`include "control_signal_types.sv"

// this is behavioral model of ALU
// not very efficient, but easy to maintain
module alu(
    input wire [31:0] a,
    input alu_t op,
    input wire [31:0] b,
    output reg [31:0] result,
    output wire zero
);
    always @(*) begin
        case (op)
            ALU_ADD : result = a + b;
            ALU_SUB : result = a - b;
            ALU_SLL : result = a << b[5:0];
            ALU_SLT : result = ($signed(a) < $signed(b)) 
                                ? 32'b1 : 32'b0;
            ALU_SLTU: result = (a < b) 
                                ? 32'b1 : 32'b0;
            ALU_XOR : result = a ^ b;
            ALU_SRL : result = a >> b[4:0];
            ALU_SRA : result = $signed(a) >>> b[4:0];
            ALU_OR  : result = a | b;
            ALU_AND : result = a & b;
            default: result = 32'bx;
        endcase
    end

    assign zero = (result == 32'b0);

endmodule