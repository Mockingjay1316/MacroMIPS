`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/10/01 09:46:06
// Design Name: 
// Module Name: sim_mux
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


module sim_mux();

reg clk50M;
reg[1:0] sel;

initial begin
    clk50M = 0;
    forever # 10
        clk50M = ~clk50M;
end

initial begin
    for (sel = 1;sel < 4; sel = sel + 1) begin
        #20;
    end
end

mux2i1o mux2(
    .d0(0),
    .d1(1),
    .sel(sel[0])
);

mux3i1o mux3(
    .d0(0),
    .d1(1),
    .d2(2),
    .sel(sel)
);

mux4i1o mux4(
    .d0(0),
    .d1(1),
    .d2(2),
    .d3(3),
    .sel(sel)
);

endmodule
