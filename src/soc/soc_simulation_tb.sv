`timescale 1ns/1ps

module soc_simulation_tb;
    reg clk;
    reg reset;

    soc_simulation m0(.clk(clk), .reset(reset));

    initial begin
        clk = 1'b0;
        reset = 1'b1;
        #5;
        reset = 1'b0;
    end

    always #50 clk = ~clk;
endmodule
