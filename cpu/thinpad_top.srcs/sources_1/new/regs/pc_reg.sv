`include "common_defs.svh"

module pc_reg (
    input   logic                       clk,            //时钟信号
    input   logic                       rst,            //pc复位
    input   logic                       stall,          //流水线暂停信号
    input   logic                       mem_stall,
    input   logic                       is_excep,       //是否是异常，如果是的话无条件转到异常入口
    input   logic                       write_en,       //写使能，高电平输入新的pc
    input   logic[`ADDR_WIDTH-1:0]      pc_in,          //pc输入

    output  logic[`ADDR_WIDTH-1:0]      pc_out          //下一条指令的pc
);

always @(posedge clk or posedge rst) begin
    if (rst) begin
        pc_out <= 32'h80000000;                         //程序入口
    end else if (is_excep) begin
        pc_out <= 32'h80001180;                         //异常入口
    end else if (stall | mem_stall) begin
        pc_out <= pc_out;
    end else if (write_en) begin
        pc_out <= pc_in;
    end else begin
        pc_out <= pc_out + 4;
    end
end

endmodule