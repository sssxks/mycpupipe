module pc #(parameter WIDTH = 32) (
    input  logic             clk,
    input  logic             reset,
    input  logic [WIDTH-1:0] pc_in,
    output logic [WIDTH-1:0] pc_out
);
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            pc_out <= 0;
        end else begin
            pc_out <= pc_in;
        end
    end
endmodule