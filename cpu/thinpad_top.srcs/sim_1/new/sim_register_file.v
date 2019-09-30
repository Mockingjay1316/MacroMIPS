`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/09/30 23:27:46
// Design Name: 
// Module Name: sim_register_file
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


module sim_register_file();

reg clk50M;
reg[31:0]   wdata;
reg[4:0]    waddr, raddr, i;
reg write_en;

initial begin
    clk50M = 0;
    forever # 10
        clk50M = ~clk50M;
end

initial begin
    write_en = 1;
    for (i = 1;i < 32; i = i + 1) begin
        #20;
        wdata[4:0] = i;
        waddr = i;
    end
end

initial begin
    #700;
    write_en = 0;
    for (i = 1;i < 32; i = i + 1) begin
        #20;
        raddr = i;
    end
end

register_file reg_file (
    .clk(clk50M),
    .write_en(write_en),
    .raddr1(raddr),
    .waddr1(waddr),
    .wdata(wdata)
);

endmodule
