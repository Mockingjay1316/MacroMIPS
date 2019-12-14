`include "common_defs.svh"

module excep_handler (
    input   excep_info_t        mem_excep_info,     //输入异常信息
    input   logic               hardware_int,
    input   logic[31:0]         Status,             //Status寄存器
    input   mmu_res_t           pc_mmu_result, data_mmu_result,
    input   pipeline_data_t     mem_pipeline_data,
    input   logic[4:0]          mem_mem_ctrl_signal,
    output  logic               is_tlb_refill,
    output  logic[7:0]          excep_code,         //输出异常码
    output  logic               is_excep,
    output  logic[31:0]         EPC_out, BadVAddr,
    output  logic[4:0]          flush
);

logic  is_tlb_data_miss, tlb_data_miss;
assign tlb_data_miss = data_mmu_result.miss | ~data_mmu_result.valid;
assign is_tlb_data_miss = (tlb_data_miss & (mem_mem_ctrl_signal[4] | mem_mem_ctrl_signal[3]));
assign is_tlb_refill = mem_excep_info.tlb_pc_miss | is_tlb_data_miss;
assign EPC_out = mem_excep_info.EPC;
//flush
//3 -> if-id
//2 -> id-ex
//1 -> ex-mem

always_comb begin
    is_excep <= 1'b0;
    flush <= 5'b00000;
    excep_code <= 8'b00000000;
    if (mem_excep_info.is_syscall) begin
        is_excep <= 1'b1;
        flush <= 5'b01110;
        excep_code[6:2] <= 5'd8;
    end else if (is_tlb_refill) begin
        is_excep <= 1'b1;
        flush <= 5'b01110;
        excep_code[6:2] <= 5'd3;
        if (is_tlb_data_miss) begin
            BadVAddr <= data_mmu_result.vaddr;
        end else begin
            BadVAddr <= mem_excep_info.EPC;
        end
    end else if (hardware_int && Status[0]) begin
        is_excep <= 1'b1;
        flush <= 5'b01110;
        excep_code[6:2] <= 5'd0;
    end

    if (Status[1] != 1'b0 || Status[2] != 1'b0) begin
        is_excep <= 1'b0;
        flush <= 5'b00000;
        excep_code <= 8'b00000000;
    end
        if (mem_excep_info.is_eret) begin
        flush <= 5'b01110;
        excep_code[6:2] <= 5'd0;
    end
    if (~mem_pipeline_data.instr_valid) begin
        is_excep <= 1'b0;
        flush <= 5'b00000;
        excep_code <= 8'b00000000;
    end
end

endmodule