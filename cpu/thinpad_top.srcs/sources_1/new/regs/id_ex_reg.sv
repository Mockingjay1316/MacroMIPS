`include "common_defs.svh"

module id_ex_reg (
    input   logic                       clk,            //时钟信号
    input   logic                       rst,            //复位信号
    input   logic[4:0]                  stall,
    input   alu_op_t                    id_alu_op,
    input   logic[`DATA_WIDTH-1:0]      id_operand1, id_operand2, id_mem_data,
    input   logic[`REGID_WIDTH-1:0]     id_reg_waddr,
    input   logic                       id_reg_write_en,
    input   logic[4:0]                  id_mem_ctrl_signal,

    output  alu_op_t                    ex_alu_op,
    output  logic[`DATA_WIDTH-1:0]      ex_operand1, ex_operand2, ex_mem_data,
    output  logic[`REGID_WIDTH-1:0]     ex_reg_waddr,
    output  logic                       ex_reg_write_en,
    output  logic[4:0]                  ex_mem_ctrl_signal
);

always @(posedge clk) begin
    if (rst) begin                      //若复位信号，则将下一级的输出置0
        ex_alu_op <= ALU_NOP;
        ex_operand1 <= `DATA_WIDTH'h00000000;
        ex_operand2 <= `DATA_WIDTH'h00000000;
        ex_reg_write_en <= 1'b0;
        ex_reg_waddr <= `REGID_WIDTH'h0;
        ex_mem_data <= `DATA_WIDTH'h00000000;
        ex_mem_ctrl_signal <= 5'b00000;
    end else if (stall == `STALL_BEF_ID) begin
        ex_alu_op <= ALU_NOP;
        ex_operand1 <= `DATA_WIDTH'h00000000;
        ex_operand2 <= `DATA_WIDTH'h00000000;
        ex_reg_write_en <= 1'b0;
        ex_reg_waddr <= `REGID_WIDTH'h0;
        ex_mem_data <= `DATA_WIDTH'h00000000;
        ex_mem_ctrl_signal <= 5'b00000;
    end else begin                      //否则将上一级的信号传递下去
        ex_alu_op <= id_alu_op;
        ex_operand1 <= id_operand1;
        ex_operand2 <= id_operand2;
        ex_reg_write_en <= id_reg_write_en;
        ex_reg_waddr <= id_reg_waddr;
        ex_mem_data <= id_mem_data;
        ex_mem_ctrl_signal <= id_mem_ctrl_signal;
    end
end

endmodule