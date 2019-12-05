`include "common_defs.svh"

module data_bus(
	Bus.slave   cpu,
	Bus.master  sram,
	Bus.master  uart
);
	assign sram.mem_wdata = cpu.mem_wdata;
	assign uart.mem_wdata = cpu.mem_wdata;


	assign sram.mem_addr = cpu.mem_addr;
	assign uart.mem_addr = cpu.mem_addr;

	logic[`DATA_WIDTH-1:0] mem_addr;
	assign mem_addr = cpu.mem_addr;

	always_comb begin
		if(cpu.mem_addr[3:0] == 4'hc | cpu.mem_addr[3:0] == 4'h8) begin
			uart.mem_ctrl_data = uart.mem_ctrl_data;
			cpu.mem_rdata = uart.mem_rdata;
		end
		else begin 
			ram.mem_ctrl_data = cpu.mem_ctrl_data;
			cpu.mem_rdata = ram.mem_rdata;
			cpu.mem_stall = ram.mem_stall
		end
	end

endmodule
