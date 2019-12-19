`include "common_defs.svh"

module id_ex_reg (
    input   logic                       clk,            //时钟信号
    input   logic                       rst,            //复位信号
    input   logic[4:0]                  stall,
    input   logic                       data_not_ready,
    input   alu_op_t                    id_alu_op,
    input   logic[`DATA_WIDTH-1:0]      id_operand1, id_operand2, id_mem_data,
    input   logic[`REGID_WIDTH-1:0]     id_reg_waddr, id_cp0_waddr,
    input   logic                       id_reg_write_en, id_cp0_write_en,
    input   logic[2:0]                  id_cp0_wsel,
    input   logic[4:0]                  id_mem_ctrl_signal,
    input   excep_info_t                id_excep_info,
    input   hilo_op_t                   id_hilo_op,
    input   pipeline_data_t             id_pipeline_data,

    output  alu_op_t                    ex_alu_op,
    output  logic[`DATA_WIDTH-1:0]      ex_operand1, ex_operand2, ex_mem_data,
    output  logic[`REGID_WIDTH-1:0]     ex_reg_waddr, ex_cp0_waddr,
    output  logic                       ex_reg_write_en, ex_cp0_write_en,
    output  logic[2:0]                  ex_cp0_wsel,
    output  logic[4:0]                  ex_mem_ctrl_signal,
    output  excep_info_t                ex_excep_info,
    output  hilo_op_t                   idex_hilo_op,
    output  pipeline_data_t             ex_pipeline_data
);

always @(posedge clk) begin
    if (rst) begin                      //若复位信号，则将下一级的输出置0
        ex_alu_op <= ALU_NOP;
        ex_operand1 <= `DATA_WIDTH'h00000000;
        ex_operand2 <= `DATA_WIDTH'h00000000;
        ex_reg_write_en <= 1'b0;
        ex_reg_waddr <= `REGID_WIDTH'h0;
        ex_cp0_write_en <= 1'b0;
        ex_cp0_waddr <= `REGID_WIDTH'h0;
        ex_cp0_wsel <= 3'b000;
        ex_mem_data <= `DATA_WIDTH'h00000000;
        ex_mem_ctrl_signal <= 5'b00000;
        ex_excep_info <= {$bits(excep_info_t){1'b0}};
        idex_hilo_op <= {$bits(hilo_op_t){1'b0}};
        ex_pipeline_data.tlb_write_en <= 1'b0;
        ex_pipeline_data.tlb_write_random <= 1'b0;
        ex_pipeline_data.instr_valid <= 1'b0;
        ex_pipeline_data.tlbp <= 1'b0;
        ex_pipeline_data.tlbr <= 1'b0;
    end else if (stall == `STALL_BEF_ID) begin
        ex_alu_op <= ALU_NOP;
        ex_operand1 <= `DATA_WIDTH'h00000000;
        ex_operand2 <= `DATA_WIDTH'h00000000;
        ex_reg_write_en <= 1'b0;
        ex_reg_waddr <= `REGID_WIDTH'h0;
        ex_cp0_write_en <= 1'b0;
        ex_cp0_waddr <= `REGID_WIDTH'h0;
        ex_cp0_wsel <= 3'b000;
        ex_mem_data <= `DATA_WIDTH'h00000000;
        ex_mem_ctrl_signal <= 5'b00000;
        ex_excep_info <= {$bits(excep_info_t){1'b0}};
        idex_hilo_op <= {$bits(hilo_op_t){1'b0}};
        ex_pipeline_data.tlb_write_en <= 1'b0;
        ex_pipeline_data.tlb_write_random <= 1'b0;
        ex_pipeline_data.instr_valid <= 1'b0;
        ex_pipeline_data.tlbp <= 1'b0;
        ex_pipeline_data.tlbr <= 1'b0;
    end else begin                      //否则将上一级的信号传递下去
        ex_alu_op <= id_alu_op;
        ex_operand1 <= id_operand1;
        ex_operand2 <= id_operand2;
        ex_reg_write_en <= id_reg_write_en;
        ex_reg_waddr <= id_reg_waddr;
        ex_cp0_write_en <= id_cp0_write_en;
        ex_cp0_waddr <= id_cp0_waddr;
        ex_cp0_wsel <= id_cp0_wsel;
        ex_mem_data <= id_mem_data;
        ex_mem_ctrl_signal <= id_mem_ctrl_signal;
        ex_excep_info <= id_excep_info;
        idex_hilo_op <= id_hilo_op;
        ex_pipeline_data <= id_pipeline_data;
    end

    if (data_not_ready) begin
        ex_alu_op <= ex_alu_op;
        ex_operand1 <= ex_operand1;
        ex_operand2 <= ex_operand2;
        ex_reg_write_en <= ex_reg_write_en;
        ex_reg_waddr <= ex_reg_waddr;
        ex_cp0_write_en <= ex_cp0_write_en;
        ex_cp0_waddr <= ex_cp0_waddr;
        ex_cp0_wsel <= ex_cp0_wsel;
        ex_mem_data <= ex_mem_data;
        ex_mem_ctrl_signal <= ex_mem_ctrl_signal;
        ex_excep_info <= ex_excep_info;
        idex_hilo_op <= idex_hilo_op;
        ex_pipeline_data <= ex_pipeline_data;
    end
end

endmodule