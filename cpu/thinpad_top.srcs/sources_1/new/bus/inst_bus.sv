`include "common_defs.svh"

module inst_bus(
	Bus.slave   cpu,
	Bus.master  sram
);
	assign sram.mem_addr = cpu.mem_addr;

	always_comb begin
		//bootroom will be added here. Then the address need to be judged.
		sram.mem_ctrl_signal = cpu.mem_ctrl_signal;
		cpu.mem_rdata = sram.mem_rdata;
		cpu.mem_stall = sram.mem_stall;
	end


endmodule