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
    clk_10M = 1'b0; # 50;
    forever begin
        clk_10M = ~clk_10M; # 50;
    end
end

initial begin
    instr = 32'b00110100000000010101010101010101; #100;         //ORI $1, $0, 0x5555
    instr = 32'b00110100000000100000000000000101; #100;         //ORI $2, $0, 0x0005
    instr = 32'b00110100000000110000000000010101; #100;         //ORI $3, $0, 0x0055
    instr = 32'b00110100000001000000000001010101; #100;         //ORI $4, $0, 0x0555
end

cpu_core cpu (
    .instruction(instr),
    .clk_50M(clk_10M)
);

endmodule
