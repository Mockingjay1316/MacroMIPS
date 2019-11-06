`include "common_defs.svh"

`define PATH_PREFIX1 "/testcase/"
module test_cpu();

logic cpu_clk, peri_clk;
logic rst, mem_stall;
logic[`INST_WIDTH-1:0] instr;
logic[`ADDR_WIDTH-1:0] pc, mem_addr;
logic[`DATA_WIDTH-1:0] mem_wdata, mem_rdata;
logic[4:0] mem_ctrl_signal;

logic [`INST_WIDTH - 1:0] inst_mem[4095:0];


cpu_core cpu (
    .instruction(instr),
    .clk_50M(clk_50M),
    .reset_btn(~rst),
    .pc_out(pc),

    .mem_addr(mem_addr),
    .mem_wdata(mem_wdata),
    .mem_rdata(mem_rdata),
    .mem_ctrl_signal(mem_ctrl_signal),
    .mem_stall(mem_stall)
);

main_pll pll (
    .clk_in1(clk_50M),
    .clk_out2(peri_clk),
    .locked(rst)
);

sram_controller sram_ctrl (
    .main_clk(clk_50M),
    .peri_clk(peri_clk),
    .rst(~rst),
    .pc(pc),
    //.instr_read(instr),
    .data_write_en(mem_ctrl_signal[3]),
    .is_data_read(mem_ctrl_signal[2]),
    .mem_byte_en(mem_ctrl_signal[1]),
    .mem_sign_ext(mem_ctrl_signal[0]),
    .data_addr(mem_addr),
    .data_write(mem_wdata),
    .data_read(mem_rdata),
    .mem_stall(mem_stall)
);

task judge(input integer fans, input integer cycle, input string out, input check_cyc);
	string ans, out_with_cyc;
	$fscanf(fans, "%s\n", ans);
	$sformat(out_with_cyc, "[%0d]%s", cycle, out);
	if(check_cyc) out = out_with_cyc;
	if(out != ans && ans != "skip")
	begin
		$display("[%0d] %s", cycle, out);
		$display("[Error] Expected: %0s, Got: %0s", ans, out);
		$stop;
	end else begin
		$display("[%0d] %s [%s]", cycle, out, ans == "skip" ? "skip" : "pass");
	end
endtask

assign reg_wr1 = cpu_core.reg_file;
task unittest(
	input [128*8 - 1:0] file_name,
	input check_cyc,
	input fpu
);

	integer i, fans, cycle = 0;
	integer is_event = 0;
	string ans, out, info;

	
	for(i = 0; i < $size(inst_mem); i = i + 1)
	inst_mem[i] = 32'h0;
	fans = $fopen({ `PATH_PREFIX1, file_name, ".ans"}, "r");
	if (fans)
	begin
		$readmemh({ `PATH_PREFIX1, name, ".mem" }, inst_mem);
	end
	inital begin
		cpu_clk = 1'b0;
		forever #10 cpu_clk = ~cpu_clk;
	end
	initial begin
		#1530
		for(i = 0; i < $size(inst_mem); i = i + 1)
		instr = inst_mem[i];    #20
	end

	$display("======= unittest: %0s =======", name);

	count = 0;
	while(!$feof(fans))
	begin @(negedge cpu_clk);
		$sformat(out, "$%0d=0x%x", reg_wr1.waddr, reg_wr1.wdata);
		judge(fans, cycle, out, check_cyc);

	end
	$display("[OK] %0s\n", file_name);
endtask

initial begin
	wait (clk.rst == 1'b0);
	unittest('inst_ori',0,0);
	unittest('inst_logic',0,0);
end

endmodule

	


