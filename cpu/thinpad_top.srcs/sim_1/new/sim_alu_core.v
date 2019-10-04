`timescale 1ns / 1ps
`include "cpu_defs.vh"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/10/04 19:10:07
// Design Name: 
// Module Name: sim_alu_core
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


module sim_alu_core(

    );

reg[31:0] d1, d2;
wire[31:0] dout;
reg[4:0] op_code;

initial begin
    op_code = `OP_ADD;
    d1 = 32'hFFFFFFFF; d2 = 32'h00000010; #10;
    d1 = 32'hFFFFFFFF; d2 = 32'h00000000; #10;
    op_code = `OP_XOR;
    d1 = 32'hFFFFFFFF; d2 = 32'h00000F11; #10;
    d1 = 32'hFFFFFFFF; d2 = 32'h00000000; #10;
end

alu_core alu (
    .op_code(op_code),
    .operand1(d1),
    .operand2(d2),
    .result(dout)
);

endmodule
