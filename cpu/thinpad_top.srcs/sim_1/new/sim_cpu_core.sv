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

logic clk_10M, rst;
logic[`INST_WIDTH-1:0] instr;

initial begin
    rst = 1'b1;
    clk_10M = 1'b0; # 10;
    clk_10M = 1'b1; # 10;
    rst = 1'b0;
    forever begin
        clk_10M = ~clk_10M; # 10;
    end
end

initial begin
    #30;
    instr = {`OP_ADDIU, 5'b00000, 5'b00001, 16'h0002}; #20;
    instr = {`OP_BNE, 5'b00000, 5'b00001, 16'hFF0F}; #20;
    instr = {`OP_XORI, 5'b00000, 5'b00011, 16'hFFFF}; #20;
    instr = {`OP_JAL, 5'b00000, 5'b00101, 16'h7FFF}; #20;
    instr = {`OP_SPECIAL, 5'b00101, 5'b00001, 5'b00001, 5'b00000, `FUNCT_ADDU}; #20;
    instr = {`OP_SPECIAL, 5'b11111, 5'b00000, 5'b00010, 5'b00000, `FUNCT_JALR}; #20;
    instr = {`OP_SPECIAL, 5'b00101, 5'b00001, 5'b00001, 5'b00000, `FUNCT_ADDU}; #20;
end

cpu_core cpu (
    .instruction(instr),
    .clk_50M(clk_10M),
    .reset_btn(rst)
);

endmodule
