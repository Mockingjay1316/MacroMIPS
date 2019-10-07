`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/10/06 16:02:41
// Design Name: 
// Module Name: sim_cpu_core
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

`include "common_defs.svh"

module sim_cpu_core(

);

logic clk_10M;
logic[`INST_WIDTH-1:0] instr;

initial begin
    clk_10M = 1'b0; # 10;
    forever begin
        clk_10M = ~clk_10M; # 10;
    end
end

initial begin
    instr = {`FUNCT_LUI, 5'b00000, 5'b00001, 16'h0002}; #100;
    instr = {`FUNCT_LUI, 5'b00000, 5'b00010, 16'hFFFF}; #100;
    instr = {`FUNCT_LUI, 5'b00000, 5'b00011, 16'hFFFF}; #100;
    instr = {`FUNCT_LUI, 5'b00000, 5'b00101, 16'h7FFF}; #100;
end

cpu_core cpu (
    .instruction(instr),
    .clk_50M(clk_10M)
);

endmodule
