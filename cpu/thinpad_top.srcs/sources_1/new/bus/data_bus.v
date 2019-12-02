`include "common_defs.svh"

module data_bus(
	Bus.slave   cpu,
	Bus.master  sram,
);
	assign sram.mem_wdata = cpu.mem_wdata;
	assign cpld.mem_wdata = cpu.mem_wdata;

	logic[`DATA_WIDTH-1:0] mem_addr;
	assign mem_addr = cpu.mem_addr;

	always_comb begin
		ram.read    = cpu.mem_ctrl_data;
        cpu.data_rdata = ram.data_rdata;
        cpu.mem_stall   = ram.mem_stall;
	end

endmodule
