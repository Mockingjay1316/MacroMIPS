`include "common_defs.svh"

module mem_wb_reg (
    input   logic                       clk,            //时钟信号
    input   logic                       rst,            //复位信号
    input   logic                       stall,
    input   logic[`REGID_WIDTH-1:0]     mem_reg_waddr, mem_cp0_waddr,
    input   logic[`DATA_WIDTH-1:0]      mem_reg_wdata,
    input   logic[2:0]                  mem_cp0_wsel,
    input   logic                       mem_reg_write_en, mem_cp0_write_en,
    input   hilo_op_t                   mem_hilo_op,
    input   pipeline_data_t             mem_pipeline_data,

    output  logic[`REGID_WIDTH-1:0]     wb_reg_waddr, wb_cp0_waddr,
    output  logic[`DATA_WIDTH-1:0]      wb_reg_wdata,
    output  logic[2:0]                  wb_cp0_wsel,
    output  logic                       wb_reg_write_en, wb_cp0_write_en,
    output  hilo_op_t                   wb_hilo_op,
    output  pipeline_data_t             wb_pipeline_data
);

always @(posedge clk) begin
    if (rst) begin                      //若复位信号，则将下一级的输出置0
        wb_reg_wdata <= `DATA_WIDTH'h00000000;
        wb_reg_write_en <= 1'b0;
        wb_reg_waddr <= `REGID_WIDTH'h0;
        wb_cp0_write_en <= 1'b0;
        wb_cp0_waddr <= `REGID_WIDTH'h0;
        wb_cp0_wsel <= 3'b000;
        wb_hilo_op <= {$bits(hilo_op_t){1'b0}};
        wb_pipeline_data <= {$bits(pipeline_data_t){1'b0}};
    end else if (stall) begin
        wb_reg_wdata <= `DATA_WIDTH'h00000000;
        wb_reg_write_en <= 1'b0;
        wb_reg_waddr <= `REGID_WIDTH'h0;
        wb_cp0_write_en <= 1'b0;
        wb_cp0_waddr <= `REGID_WIDTH'h0;
        wb_cp0_wsel <= 3'b000;
        wb_hilo_op <= {$bits(hilo_op_t){1'b0}};
        wb_pipeline_data <= {$bits(pipeline_data_t){1'b0}};
    end else begin                      //否则将上一级的信号传递下去
        wb_reg_wdata <= mem_reg_wdata;
        wb_reg_write_en <= mem_reg_write_en;
        wb_reg_waddr <= mem_reg_waddr;
        wb_cp0_write_en <= mem_cp0_write_en;
        wb_cp0_waddr <= mem_cp0_waddr;
        wb_cp0_wsel <= mem_cp0_wsel;
        wb_hilo_op <= mem_hilo_op;
        wb_pipeline_data <= mem_pipeline_data;
    end
end

endmodule