`include "common_defs.svh"

module data_bus(
	Bus.slave   cpu,
	Bus.master  sram,
	Bus.master  uart
);
	assign sram.mem_wdata = cpu.mem_wdata;
	assign sram.mem_addr = cpu.mem_addr;
	assign cpu.stall = sram.stall;
	assign cpu.mem_rdata = sram.mem_rdata;


	assign uart.mem_wdata = cpu.mem_wdata;

endmodule
