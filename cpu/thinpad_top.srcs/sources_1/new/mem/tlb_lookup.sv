`include "common_defs.svh"

module tlb_lookup (
    input   tlb_flat_entry_t    tlb_flat_entry,
    input   logic[31:0]         vaddr,
    input   logic[7:0]          asid,
    output  tlb_res_t           result
);

tlb_entry_t entries[`MMU_SIZE_NUM-1:0];
logic[`MMU_SIZE_NUM-1:0]    hits;
logic[`MMU_SIZE_NUM_LOG2-1:0]   hit_index;
tlb_entry_t hit_entry;

assign hit_entry = entries[hit_index];
assign result.miss = (hits == 16'b0);
assign result.index = hit_index;
assign result.paddr[11:0] = vaddr[11:0];

always_comb begin
    if (vaddr[12]) begin
        result.dirty = hit_entry.PFN1_fl[1];
        result.valid = hit_entry.PFN1_fl[0];
        result.cache_fl = hit_entry.PFN1_fl[4:2];
        result.paddr[31:12] = hit_entry.PFN1[19:0];
    end else begin
        result.dirty = hit_entry.PFN0_fl[1];
        result.valid = hit_entry.PFN0_fl[0];
        result.cache_fl = hit_entry.PFN0_fl[4:2];
        result.paddr[31:12] = hit_entry.PFN0[19:0];
    end
end

always_comb begin
    hit_index <= 0;
    if (hits[0]) hit_index <= 0;
    else if (hits[1])  hit_index <= 1;
    else if (hits[2])  hit_index <= 2;
    else if (hits[3])  hit_index <= 3;
    else if (hits[4])  hit_index <= 4;
    else if (hits[5])  hit_index <= 5;
    else if (hits[6])  hit_index <= 6;
    else if (hits[7])  hit_index <= 7;
    else if (hits[8])  hit_index <= 8;
    else if (hits[9])  hit_index <= 9;
    else if (hits[10]) hit_index <= 10;
    else if (hits[11]) hit_index <= 11;
    else if (hits[12]) hit_index <= 12;
    else if (hits[13]) hit_index <= 13;
    else if (hits[14]) hit_index <= 14;
    else if (hits[15]) hit_index <= 15;
end

genvar i;
generate
for (i = 0; i < `MMU_SIZE_NUM; i = i + 1)
begin: gen_tlb_match
    assign entries[i] = tlb_flat_entry[(i + 1) * $bits(tlb_entry_t) - 1:i * $bits(tlb_entry_t)];
    assign hits[i] = (entries[i].VPN2 == vaddr[31:13] && (entries[i].ASID == asid || entries[i].G) && entries[i].inited);
end
endgenerate

endmodule