`include "common_defs.svh"

module memory_unit (
    input   logic                   clk, rst,
    input   logic[31:0]             pc_in, mem_addr_in,

    output  logic[31:0]             pc_out, mem_addr_out
);

tlb_entry_t tlb_entries[`MMU_SIZE_NUM:0];

always_comb begin
    pc_out <= pc_in;
    mem_addr_out <= mem_addr_in;
end

endmodule