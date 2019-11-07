`include "common_defs.svh"

module memory_unit (
    input   logic[31:0]             pc_in, mem_addr_in,

    output  logic[31:0]             pc_out, mem_addr_out
);

always_comb begin
    pc_out <= pc_in;
    mem_addr_out <= mem_addr_in;
end

endmodule