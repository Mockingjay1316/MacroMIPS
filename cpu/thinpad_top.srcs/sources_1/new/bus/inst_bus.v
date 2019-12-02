`include "common_defs.svh"

module inst_bus(
	Bus.slave   cpu,
	Bus.master  sram
);
	assign sram.mem_addr = cpu.mem_addr;

	always_comb begin
		sram.read      = 1'b0;
        sram.write     = 1'b0;
        cpu.data_rd    = 32'h0;
        cpu.stall      = 1'b0;
		
		//bootroom will be added here. Then the address need to be judged.
		ram.mem_ctrl_signal = cpu.mem_ctrl_signal;
		cpu.mem_rdata = ram.mem_rdata;
		cpu.mem_stall = ram.mem_stall;
	end


endmodule