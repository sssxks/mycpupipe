

module mux2to1 #(parameter WIDTH = 32) (
    input  logic [WIDTH-1:0] in0,
    input  logic [WIDTH-1:0] in1,
    input  logic             sel,
    output logic [WIDTH-1:0] out
);
    assign out = sel ? in1 : in0;
endmodule

module adder #(parameter WIDTH = 32) (
    input  logic [WIDTH-1:0] a,
    input  logic [WIDTH-1:0] b,
    output logic [WIDTH-1:0] sum
);
    assign sum = a + b;
endmodule

module PC #(parameter WIDTH = 32) (
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

module if_stage (
    input  logic        clk,
    input  logic        reset,
    input  logic [31:0] instr_in,
    output logic [31:0] instr_out,
    output logic [31:0] pc_out
);
    // Internal signals
    logic [31:0] pc_next;
    logic [31:0] pc_reg;
    logic [31:0] instr_reg;
    
    // Instantiate PC module
    PC #(.WIDTH(32)) pc (
        .clk(clk),
        .reset(reset),
        .pc_in(pc_next),
        .pc_out(pc_reg)
    );
    
    // Assign PC next value
    assign pc_next = pc_reg + 4;
    // Instantiate adder module to calculate pc_next
    adder #(.WIDTH(32)) pc_adder (
        .a(pc_reg),
        .b(32'd4),
        .sum(pc_next)
    );
    
    // Assign output signals
    assign instr_out = instr_reg;
    assign pc_out = pc_reg;
    
    // Register instr_in
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            instr_reg <= 0;
        end else begin
            instr_reg <= instr_in;
        end
    end    
endmodule