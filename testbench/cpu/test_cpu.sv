`include "common_defs.svh"

`define PATH_PREFIX1 "../../../../../testbench/cpu/testcase/"
module test_cpu();

logic rst, mem_stall;
logic clk_50M;
logic[`INST_WIDTH-1:0] instr;
logic[`ADDR_WIDTH-1:0] pc, mem_addr;
logic[`DATA_WIDTH-1:0] mem_wdata, mem_rdata;
logic[4:0] mem_ctrl_signal;

logic [`INST_WIDTH - 1:0] inst_mem[4095:0];

initial begin
    clk_50M = 1'b0; # 10;
    clk_50M = 1'b1; # 10;
    forever begin
        clk_50M = ~clk_50M; # 10;
    end
end

initial begin
#20;
forever begin
    instr = inst_mem[pc[13:2]];
    #20;
    end
end

cpu_core cpu(
    .instruction(instr),
    .clk_50M(clk_50M),
    .reset_btn(rst),
    .pc_out(pc),

    .mem_addr(mem_addr),
    .mem_wdata(mem_wdata),
    .mem_rdata(mem_rdata),
    .mem_ctrl_signal(mem_ctrl_signal),
    .mem_stall(mem_stall)
);

task judge(input integer fans, input integer cycle, input string out);
	string ans;
	$fscanf(fans, "%s\n", ans);
	if(out != ans && ans != "skip")
	begin
		$display("[%0d] %s", cycle, out);
		$display("[Error] Expected: %0s, Got: %0s", ans, out);
		//$stop;
	end else begin
		$display("[%0d] %s [%s]", cycle, out, ans == "skip" ? "skip" : "pass");
	end
endtask

logic[4:0] reg_addr;
logic[31:0] reg_data, write_data, cp0_wdata;
logic[63:0] hilo;
logic hilo_write_en, reg_write_en, cp0_write_en, mem_write_en;
logic read_en;
logic[4:0] cp0_waddr;

assign reg_addr = cpu.wb_reg_waddr;
assign reg_data = cpu.wb_reg_wdata;
assign reg_write_en = cpu.reg_file_r.write_en;

assign hilo = cpu.hilo_reg_r.hilo_op.hilo_wval;
assign hilo_write_en = cpu.hilo_reg_r.hilo_op.hilo_write_en;

assign cp0_write_en = cpu.cp0_reg_r.write_en;
assign cp0_wdata = cpu.cp0_reg_r.wdata;
assign cp0_waddr = cpu.cp0_reg_r.waddr;

assign mem_write_en = mem_ctrl_signal[3];
assign load_from_en = mem_ctrl_signal[4];


task unittest(
	input [128*8 - 1:0] file_name
);
	//
	integer i, fans, count, mem_index = 0;
	integer begin_count = 0;
	string ans, out, info;
	for(i = 0; i < $size(inst_mem); i = i + 1)
		inst_mem[i] = 32'h0;
	begin
		$readmemh({ `PATH_PREFIX1, file_name, ".mem" }, inst_mem);
	end
	fans = $fopen({ `PATH_PREFIX1, file_name, ".ans"}, "r");
	
	i = 0;
	begin
		rst = 1'b1;
		#20 rst = 1'b0;
	end
	
	$display("======= unittest: %0s =======", file_name);
	count = 0;
	//instr = inst_mem[count];
	while(!$feof(fans))
	begin @(negedge clk_50M);
		count = count + 1;
		if (hilo_write_en)
		begin
			$sformat(out, "$hilo=0x%x%x", hilo[31:0], hilo[63:32]);
			judge(fans, count, out);
		end else begin
		if(cp0_write_en)
		begin 
			$sformat(out, "cp%0d=0x%x", cp0_waddr, cp0_wdata);
			judge(fans, count, out);
		end else
		if (reg_addr && reg_data)
	    begin
			$sformat(out, "$%0d=0x%x", reg_addr, reg_data);
			judge(fans, count, out);
		end else
		if(mem_write_en) 
		begin
			$sformat(out, "[0x%x]=0x%x", mem_addr[15:0], mem_wdata);
			judge(fans, count, out);
		end 
		end
		
	end
	$display("%0s pass!\n", file_name);
endtask

initial begin
    rst = 1'b1;
    /*unittest("inst_ori");
	rst = 1'b1;
	unittest("inst_logic");
	rst = 1'b1;
	unittest("inst_ori");
	rst = 1'b1;
	unittest("inst_arith");
	rst = 1'b1;
	unittest("inst_shift");
	rst = 1'b1;
	unittest("inst_multi");
	rst = 1'b1;
	unittest("inst_branch");
	rst = 1'b1;
	unittest("inst_jump");
	rst = 1'b1;
	unittest("cp0_test");*/
	$finish;
end
endmodule

	


