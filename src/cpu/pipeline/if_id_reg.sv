module if_id_reg (
    input logic clk,
    input logic reset,
    input logic [31:0] if_pc,
    input logic [31:0] if_instruction,
    output logic [31:0] id_pc,
    output logic [31:0] id_instruction
);

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            id_pc <= 32'b0;
            id_instruction <= 32'b0;
        end else begin
            id_pc <= if_pc;
            id_instruction <= if_instruction;
        end
    end

endmodule