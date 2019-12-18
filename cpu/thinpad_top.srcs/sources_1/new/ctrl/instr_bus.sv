`include "common_defs.svh"

module instr_bus (
    input   logic[31:0]         pc,
    output  logic[31:0]         instr,
    output  logic               mem_stall,
    output  logic[31:0]         sram_pc, rom_pc,
    input   logic[31:0]         sram_instr, rom_instr,
    input   logic               sram_mem_stall
);

assign sram_pc = pc;
assign rom_pc  = pc;

always_comb begin
    if (pc[27:20] == 8'hfc) begin
        instr <= rom_instr;
        mem_stall <= 1'b0;
    end else begin
        instr <= sram_instr;
        mem_stall <= sram_mem_stall;
    end
end

endmodule