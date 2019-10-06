`include "common_defs.svh"

module mem_wb_reg (
    input   logic                       clk,            //时钟信号
    input   logic                       rst,            //复位信号
    input   logic[`REGID_WIDTH-1:0]     mem_reg_waddr,
    input   logic[`DATA_WIDTH-1:0]      mem_reg_wdata,
    input   logic                       mem_reg_write_en,

    output  logic[`REGID_WIDTH-1:0]     wb_reg_waddr,
    output  logic[`DATA_WIDTH-1:0]      wb_reg_wdata,
    output  logic                       wb_reg_write_en
);

always @(posedge clk) begin
    if (rst) begin                      //若复位信号，则将下一级的输出置0
        wb_reg_wdata <= `DATA_WIDTH'h00000000;
        wb_reg_write_en <= 1'b0;
        wb_reg_waddr <= `REGID_WIDTH'h0;
    end else begin                      //否则将上一级的信号传递下去
        wb_reg_wdata <= mem_reg_wdata;
        wb_reg_write_en <= mem_reg_write_en;
        wb_reg_waddr <= mem_reg_waddr;
    end
end

endmodule