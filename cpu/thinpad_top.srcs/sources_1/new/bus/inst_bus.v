`include "common_defs.svh"

module inst_bus(
	Bus.slave   cpu,
	Bus.master  sram
);
	assign ram.mem_addr = cpu.mem_addr;

	always begin
		sram.mem_rdata = cpu.mem_rdata;
		sram.mem_wdata = cpu.mem_wdata;

		cpu.mem_stall = sram.mem_stall;
		cpu.data_read = sram.data_read;
	end


endmodule