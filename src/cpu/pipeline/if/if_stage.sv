module if_stage (
    input  logic        clk,
    input  logic        reset,
    input  logic        enable,

    input  logic [31:0] pc_in,
    input  logic        PCSrc,
    output logic [31:0] pc_out
);
    logic [31:0] pc_next;
    logic [31:0] pc_curr;
    
    pc #(.WIDTH(32)) pc_instance (
        .clk(clk),
        .reset(reset),
        .pc_in(pc_next),
        .pc_out(pc_curr)
    );
    
    assign pc_next = PCSrc ? pc_in : pc_curr + 32'd4;
    assign pc_out = pc_curr;
endmodule