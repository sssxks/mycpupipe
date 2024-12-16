`timescale 1ns/1ps

module soc_simulation_tb;
    reg clk;
    reg reset;

    soc_simulation m0(.clk(clk), .reset(rst));

    initial begin
        clk = 1'b0;
        rst = 1'b1;
        #5;
        rst = 1'b0;
    end

    always #50 clk = ~clk;
endmodule
