`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/10/03 19:45:42
// Design Name: 
// Module Name: sim_sign_extend
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


module sim_sign_extend(

    );

reg[15:0] data_in;
wire[31:0] data_out;

initial begin
    data_in = 16'hFFFF; #10;
    data_in = 16'h0001; #10;
    data_in = 16'hF0F0; #10;
end

sign_extend signext(
    .data_in(data_in),
    .data_out(data_out)
);

endmodule
