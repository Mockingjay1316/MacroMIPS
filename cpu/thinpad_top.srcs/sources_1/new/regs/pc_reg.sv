`include "common_defs.svh"

module pc_reg (
    input   logic                       clk,            //时钟信号
    input   logic                       rst,            //pc复位
    input   logic                       write_en,       //写使能，高电平输入新的pc
    input   logic[`ADDR_WIDTH-1:0]      pc_in,          //pc输入

    output  logic[`ADDR_WIDTH-1:0]      pc_out          //下一条指令的pc
);

always @(posedge clk) begin
    if (rst) begin
        pc_out <= 32'h80000000;
    end else if (write_en) begin
        pc_out <= pc_in;
    end else begin
        pc_out <= pc_out + 4;
    end
end

endmodule