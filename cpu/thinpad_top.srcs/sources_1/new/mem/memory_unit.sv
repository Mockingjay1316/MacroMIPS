`include "common_defs.svh"

module memory_unit (
    input   logic                   clk, rst,
    input   logic[31:0]             pc_in, mem_addr_in,
    input   logic                   tlb_write_en,
    input   logic[31:0]             index, EntryHi, PageMask, EntryLo1, EntryLo0,

    output  logic                   pc_tlb_hit, mem_tlb_hit,
    output  logic[31:0]             pc_out, mem_addr_out
);

tlb_entry_t tlb_entries[`MMU_SIZE_NUM:0];
logic[`MMU_SIZE_NUM:0] pc_res, mem_addr_res;
integer i, j;

always_comb begin
    if (rst) begin
        pc_tlb_hit <= 1'b0;
        mem_tlb_hit <= 1'b0;
    end else begin
        if (pc_in >= 32'h80000000 && pc_in < 32'hC0000000) begin
            pc_out <= pc_in;
            pc_tlb_hit <= 1'b1;
        end else begin
            for (i = 0; i <= `MMU_SIZE; ++i) begin
                if (pc_in[31:13] & {3'b111, ~tlb_entries[i].PageMask[28:13]} == tlb_entries[i].VPN2) begin
                    pc_res[i] <= 1'b1;
                    pc_tlb_hit <= 1'b1;
                    if (pc_in[12] == 1'b0) begin
                        pc_out <= {tlb_entries[i].PFN0, pc_in[11:0]};
                    end else if (pc_in[12] == 1'b1) begin
                        pc_out <= {tlb_entries[i].PFN1, pc_in[11:0]};
                    end
                end else begin
                    pc_res[i] <= 1'b0;
                end
            end
        end
        if (mem_addr_in >= 32'h80000000 && mem_addr_in < 32'hC0000000) begin
            mem_addr_out <= mem_addr_in;
            mem_tlb_hit <= 1'b1;
        end else begin
            for (j = 0; j <= `MMU_SIZE; ++j) begin
                if (mem_addr_in[31:13] & {3'b111, ~tlb_entries[j].PageMask[28:13]} == tlb_entries[j].VPN2) begin
                    mem_addr_res[j] <= 1'b1;
                    mem_tlb_hit <= 1'b1;
                    if (mem_addr_in[12] == 1'b0) begin
                        mem_addr_out <= {tlb_entries[j].PFN0, mem_addr_in[11:0]};
                    end else if (mem_addr_in[12] == 1'b1) begin
                        mem_addr_out <= {tlb_entries[j].PFN1, mem_addr_in[11:0]};
                    end
                end else begin
                    mem_addr_res[j] <= 1'b0;
                end
            end
        end
    end
end

always @(posedge clk) begin
    if (tlb_write_en) begin
        tlb_entries[index[`MMU_SIZE_NUM:0]].VPN2 <= EntryHi[31:13];
        tlb_entries[index[`MMU_SIZE_NUM:0]].PageMask <= PageMask;
        tlb_entries[index[`MMU_SIZE_NUM:0]].PFN0 <= EntryLo0[31:6];
        tlb_entries[index[`MMU_SIZE_NUM:0]].PFN0_fl <= EntryLo0[5:1];
        tlb_entries[index[`MMU_SIZE_NUM:0]].PFN1 <= EntryLo1[31:6];
        tlb_entries[index[`MMU_SIZE_NUM:0]].PFN1_fl <= EntryLo1[5:1];
    end
end

endmodule