`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/10/10 18:50:48
// Design Name: 
// Module Name: sim_dist_mem
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


module sim_dist_mem(

    );

logic[5:0] addr1, addr2;
logic[15:0] wdata, rdata1, rdata2;
logic clk, write_en;

initial begin
    clk = 1'b0; #10;
    forever begin
        clk = ~clk; #10;
    end
end

initial begin
    write_en = 1;
    addr1 = 6'b000001;
    addr2 = 6'b000000;
    wdata = 16'd11; #20;
    addr1 = 6'b000010;
    addr2 = 6'b000001;
    wdata = 16'd12; #20;
end

dist_mem mem (
    .a(addr1),
    .dpra(addr2),
    .d(wdata),
    .clk(clk),
    .we(write_en),
    .spo(rdata1),
    .dpo(rdata2)
);

endmodule
