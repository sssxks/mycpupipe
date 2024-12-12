`timescale 1ns/1ps

module regs(
    input wire clk, rst, reg_write,
    input wire [4:0] rs1_addr, rs2_addr, wt_addr,
    input wire [31:0] wt_data,
    output wire [31:0] rs1_data, rs2_data
);
    reg [31:0] register [1:31]; // x1 - x31, x0 is hard wired to 0
    
    assign rs1_data = (rs1_addr == 0) ? 0 : register[rs1_addr];
    assign rs2_data = (rs2_addr == 0) ? 0 : register[rs2_addr];

    integer i;
    always @(posedge clk or posedge rst) begin
        if (rst == 1) begin
            for (i = 1; i < 32; i = i + 1)
                register[i] <= 0; // reset
        end else if ((wt_addr != 0) && (reg_write == 1))
            register[wt_addr] <= wt_data; // write
    end
endmodule