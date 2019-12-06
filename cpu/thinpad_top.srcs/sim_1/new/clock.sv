`include "common_defs.svh"
`timescale 1ps / 1ps

module clock (
    output Clock clk
);

initial begin 
    clk.reset_btn = 0;
    clk.clk_50M = 0;
    clk.clk_11M0592 = 0;
end

always #(90422/2) clk.clk_11M0592 = ~clk.clk_11M0592;
always #(20000/2) clk.clk_50M = ~clk.clk_50M;

endmodule
