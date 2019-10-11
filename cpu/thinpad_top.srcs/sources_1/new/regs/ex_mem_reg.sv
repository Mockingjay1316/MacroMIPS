`include "common_defs.svh"

module ex_mem_reg (
    input   logic                       clk,            //时钟信号
    input   logic                       rst,            //复位信号
    input   logic                       stall,
    input   logic[`REGID_WIDTH-1:0]     ex_reg_waddr,
    input   logic[`DATA_WIDTH-1:0]      ex_alu_result,
    input   logic                       ex_reg_write_en,

    output  logic[`REGID_WIDTH-1:0]     mem_reg_waddr,
    output  logic[`DATA_WIDTH-1:0]      mem_alu_result,
    output  logic                       mem_reg_write_en
);

always @(posedge clk) begin
    if (rst) begin                      //若复位信号，则将下一级的输出置0
        mem_alu_result <= `DATA_WIDTH'h00000000;
        mem_reg_write_en <= 1'b0;
        mem_reg_waddr <= `REGID_WIDTH'h0;
    end else if (stall) begin
        mem_alu_result <= `DATA_WIDTH'h00000000;
        mem_reg_write_en <= 1'b0;
        mem_reg_waddr <= `REGID_WIDTH'h0;
    end else begin                      //否则将上一级的信号传递下去
        mem_alu_result <= ex_alu_result;
        mem_reg_write_en <= ex_reg_write_en;
        mem_reg_waddr <= ex_reg_waddr;
    end
end

endmodule