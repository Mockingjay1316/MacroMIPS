`include "common_defs.svh"

module excep_handler (
    input   excep_info_t        mem_excep_info,     //输入异常信息
    input   logic               hardware_int,
    input   logic[31:0]         Status,             //Status寄存器
    output  logic[7:0]          excep_code,         //输出异常码
    output  logic               is_excep,
    output  logic[31:0]         EPC_out,
    output  logic[4:0]          flush
);

assign EPC_out = mem_excep_info.EPC;
//flush
//3 -> if-id
//2 -> id-ex
//1 -> ex-mem

always_comb begin
    is_excep <= 1'b0;
    flush <= 5'b00000;
    excep_code <= 8'b00000000;
    if (mem_excep_info.is_excep) begin
        is_excep <= 1'b1;
        flush <= 5'b01110;
        excep_code[6:2] <= 5'd8;
    end else if (hardware_int) begin
        is_excep <= 1'b1;
        flush <= 5'b01110;
        excep_code[6:2] <= 5'd0;
    end

    if (Status[1] != 1'b0 || Status[2] != 1'b0) begin
        is_excep <= 1'b0;
        flush <= 5'b00000;
        excep_code <= 8'b00000000;
    end else if (Status[0] == 1'b0) begin
        is_excep <= 1'b0;
        flush <= 5'b00000;
        excep_code <= 8'b00000000;
    end
end

endmodule