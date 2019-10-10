`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/10/10 20:12:24
// Design Name: 
// Module Name: sim_fifo
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


module sim_fifo(

    );

logic[5:0] addr1, addr2;
logic[17:0] wdata, rdata1, rdata2;
logic clk_wr, clk_rd, write_en, read_en, rst;

initial begin
    clk_wr = 1'b0; #10;
    forever begin
        clk_wr = ~clk_wr; #10;
    end
end

initial begin
    clk_rd = 1'b0; #11;
    forever begin
        clk_rd = ~clk_rd; #11;
    end
end

initial begin
    rst = 1'b0; #40;
    rst = 1'b0;
    read_en = 0;
    write_en = 1;
    wdata = 18'd11; #20;
    wdata = 18'd12; #20;
    read_en = 1;
    write_en = 0;
end

fifo my_fifo (
    .din(wdata),
    .wr_clk(clk_wr),
    .rd_clk(clk_rd),
    .wr_en(write_en),
    .rd_en(read_en)//,
    //.rst(rst)
);

endmodule
