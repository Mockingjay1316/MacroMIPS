`include "common_defs.svh"

module memory_unit (
    input   logic                   clk, rst,
    input   logic[31:0]             pc_in, mem_addr_in,
    input   logic                   tlb_write_en,
    input   logic[31:0]             index, EntryHi, PageMask, EntryLo1, EntryLo0,

    output  logic                   pc_tlb_hit, mem_tlb_hit,
    output  logic[31:0]             pc_out, mem_addr_out, tlbp_index,
    output  mmu_res_t               pc_mmu_result, data_mmu_result,
    output  tlb_entry_t             tlb_rdata
);

logic pc_mapped, data_mapped;
tlb_res_t pc_result, data_result;

assign pc_mapped = (~pc_in[31] || pc_in[31:30] == 2'b11);
assign data_mapped = (~mem_addr_in[31] || mem_addr_in[31:30] == 2'b11);

assign pc_mmu_result.dirty = 1'b0;
assign pc_mmu_result.miss = pc_mapped & pc_result.miss;
assign pc_mmu_result.illegal = 1'b0;
assign pc_mmu_result.valid = ~pc_mapped | pc_result.valid;
assign pc_mmu_result.paddr = pc_mapped ? pc_result.paddr : pc_in;
assign pc_mmu_result.vaddr = pc_in;

assign data_mmu_result.dirty = ~data_mapped | data_result.dirty;
assign data_mmu_result.miss = data_mapped & data_result.miss;
assign data_mmu_result.illegal = 1'b0;
assign data_mmu_result.valid = ~data_mapped | data_result.valid;
assign data_mmu_result.paddr = data_mapped ? data_result.paddr : mem_addr_in;
assign data_mmu_result.vaddr = mem_addr_in;

tlb_entry_t tlb_wdata;
assign tlb_wdata = {EntryHi[31:13], EntryHi[7:0], PageMask, EntryLo0[0], EntryLo0[31:6], EntryLo1[31:6], EntryLo0[5:1], EntryLo1[5:1], 1'b1};

tlb tlb_r (
    .clk,
    .rst,
    .pc_vaddr(pc_in),
    .data_vaddr(mem_addr_in),
    .pc_result,
    .data_result,
    .asid(8'b0),

    .tlb_index(index[3:0]),
    .tlb_write_en,
    .tlb_wdata,
    .tlb_rdata,

    .tlbp_entryhi(EntryHi),
    .tlbp_index
);

endmodule