`include "common_defs.svh"

module if_id_reg (
    input   logic                       clk,            //时钟信号
    input   logic                       rst,            //复位信号,也接受flush信号
    input   logic                       stall,
    input   logic                       data_not_ready,
    input   logic[`ADDR_WIDTH-1:0]      if_pc,          //if段的pc
    input   logic[`INST_WIDTH-1:0]      if_inst,        //if段取到的指令
    input   logic                       if_after_branch,
    input   excep_info_t                if_excep_info,

    output  logic[`ADDR_WIDTH-1:0]      id_pc,          //id段的pc
    output  logic[`INST_WIDTH-1:0]      id_inst,        //id段的指令
    output  logic                       id_after_branch,
    output  excep_info_t                ifid_excep_info
);

always @(posedge clk) begin
    if (rst) begin                      //若复位信号，则将下一级的输出置0
        id_pc <= 32'h00000000;
        id_inst <= 32'h00000000;
        id_after_branch <= 1'b0;
        ifid_excep_info <= {$bits(excep_info_t){1'b0}};
    end else if (stall) begin
        id_pc <= id_pc;
        id_inst <= id_inst;
        id_after_branch <= id_after_branch;
        ifid_excep_info <= {$bits(excep_info_t){1'b0}};
    end else begin                      //否则将上一级的信号传递下去
        id_pc <= if_pc;
        id_inst <= if_inst;
        id_after_branch <= if_after_branch;
        ifid_excep_info <= if_excep_info;
    end

    if (data_not_ready) begin
        id_pc <= id_pc;
        id_inst <= id_inst;
        id_after_branch <= id_after_branch;
        ifid_excep_info <= ifid_excep_info;
    end
end

endmodule