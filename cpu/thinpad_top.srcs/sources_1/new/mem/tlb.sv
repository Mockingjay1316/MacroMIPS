`include "common_defs.svh"

module tlb (
    input   logic       clk, rst,
    input   logic[7:0]  asid,
    input   logic[31:0] pc_vaddr, data_vaddr,
    output  tlb_res_t   pc_result, data_result,

    input   logic[3:0]  tlb_index,
    input   logic       tlb_write_en,
    input   tlb_entry_t tlb_wdata,
    output  tlb_entry_t tlb_rdata,

    input   logic[31:0] tlbp_entryhi,
    output  logic[31:0] tlbp_index
);

tlb_flat_entry_t tlb_flat_entry;
tlb_entry_t entries[`MMU_SIZE_NUM-1:0];
assign tlb_rdata = entries[tlb_index];

genvar i;
generate
for (i = 0; i < `MMU_SIZE_NUM; i = i + 1)
begin: gen_tlb_match
    assign entries[i] = tlb_flat_entry[(i + 1) * $bits(tlb_entry_t) - 1:i * $bits(tlb_entry_t)];
    always @ (posedge clk) begin
        if (rst) begin
            tlb_flat_entry[(i + 1) * $bits(tlb_entry_t) - 1:i * $bits(tlb_entry_t)] <= {$bits(tlb_entry_t){1'b0}};
        end else if (tlb_write_en && i == tlb_index) begin
            tlb_flat_entry[(i + 1) * $bits(tlb_entry_t) - 1:i * $bits(tlb_entry_t)] <= tlb_wdata;
        end
    end
end
endgenerate

tlb_lookup pc_lookup (
    .tlb_flat_entry,
    .vaddr(pc_vaddr),
    .asid,
    .result(pc_result)
);

tlb_lookup data_lookup (
    .tlb_flat_entry,
    .vaddr(data_vaddr),
    .asid,
    .result(data_result)
);

tlb_res_t tlbp_result;
tlb_lookup tlbp_lookup (
    .tlb_flat_entry,
    .vaddr(tlbp_entryhi),
    .asid(tlbp_entryhi[7:0]),
    .result(tlbp_result)
);
assign tlbp_index = {tlbp_result.miss, {27{1'b0}}, tlbp_result.index};

endmodule