`include "common_defs.svh"

module reg_file (
    input   logic                       clk,                        //寄存器堆的时钟信号
    input   logic                       rst,                        //寄存器复位信号
    input   logic                       write_en,                   //写使能
    input   logic[`REGID_WIDTH-1:0]     raddr1, raddr2, waddr,      //读和写的地址
    input   logic[`DATA_WIDTH-1:0]      wdata,

    output  logic[`DATA_WIDTH-1:0]      rdata1, rdata2              //读出来的地址
);

logic[`DATA_WIDTH-1:0] regs[`REGISTER_NUM:0];

always @(posedge clk) begin
    if (write_en) begin
        regs[waddr] <= wdata;
    end
end

always @(*) begin                                                   //读寄存器是不等时钟信号的
    if (write_en && raddr1 === waddr) begin
        rdata1 <= wdata;
    end else begin
        rdata1 <= (raddr1 == 0) ? 0 : regs[raddr1];
    end

    if (write_en && raddr2 === waddr) begin
        rdata2 <= wdata;
    end else begin
        rdata2 <= (raddr2 == 0) ? 0 : regs[raddr2];
    end

    if (rst) begin
        rdata1 <= 32'h00000000;
        rdata2 <= 32'h00000000;
    end
end

endmodule