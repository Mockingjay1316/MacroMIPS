`include "common_defs.svh"

module pc_reg (
    input   logic                       clk,            //时钟信号
    input   logic                       rst,            //pc复位
    input   logic                       stall,          //流水线暂停信号
    input   logic                       mem_stall, data_not_ready,
    input   logic                       is_excep,       //是否是异常，如果是的话无条件转到异常入口
    input   logic                       is_tlb_refill,  //TLB重填异常
    input   logic                       write_en,       //写使能，高电平输入新的pc
    input   logic                       is_eret,
    input   logic[`ADDR_WIDTH-1:0]      epc,            //epc
    input   logic[`ADDR_WIDTH-1:0]      ebase,          //ebase
    input   logic[`ADDR_WIDTH-1:0]      pc_in,          //pc输入

    output  logic[`ADDR_WIDTH-1:0]      pc_out          //下一条指令的pc
);

logic [1:0] cnt;

always @(posedge clk) begin
    if (rst) begin
        cnt <= 2'b11;
    end else begin
        if (cnt >= 1) begin
            cnt <= cnt - 1;
        end
    end
    if (rst) begin
        //pc_out <= 32'h80000000;                         //程序入口
        pc_out <= 32'hbfc00000;
    end else if (cnt > 0) begin
        //pc_out <= 32'h80000000;                         //程序入口
        pc_out <= 32'hbfc00000;
    end else if (is_tlb_refill & is_excep) begin
        pc_out <= ebase;                                //重填异常入口
    end else if (is_excep) begin
        pc_out <= ebase + 12'h180;                      //异常入口
    end else if (stall | mem_stall) begin
        pc_out <= pc_out;
    end else if (write_en) begin
        pc_out <= pc_in;
    end else begin
        pc_out <= pc_out + 4;
    end

    if (is_eret) begin
        pc_out <= epc;
    end

    if (data_not_ready) begin
        pc_out <= pc_out;
    end
end

endmodule