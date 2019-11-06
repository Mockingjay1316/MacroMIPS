`include "common_defs.svh"

`define PATH_PREFIX1 "//Mac/Home/Desktop/MarcoMips/testbench/cpu/testcase/"
module test_cpu();

logic cpu_clk, peri_clk;
logic rst, mem_stall;
logic[`INST_WIDTH-1:0] instr;
logic[`ADDR_WIDTH-1:0] pc, mem_addr;
logic[`DATA_WIDTH-1:0] mem_wdata, mem_rdata;
logic[4:0] mem_ctrl_signal;

logic [`INST_WIDTH - 1:0] inst_mem[4095:0];

initial begin
    cpu_clk = 1'b0; # 10;
    cpu_clk = 1'b1; # 10;
    forever begin
        cpu_clk = ~cpu_clk; # 10;
    end
end

/*initial begin
    #20;
    instr = {`OP_ORI, 5'b00000, 5'b00001, 16'h0002}; #20;
    //instr = {`OP_LW, 5'b00000, 5'b00001, 16'h0002}; #20;
    //instr = {`OP_ORI, 5'b00001, 5'b00010, 16'h0042}; #20;
    instr = {`OP_ORI, 5'b00000, 5'b00001, 16'h0002}; #20;
    instr = {`OP_ORI, 5'b00000, 5'b00010, 16'h0002}; #20;
    instr = {`OP_ORI, 5'b00000, 5'b00011, 16'h0002}; #20;
    instr = {`OP_ORI, 5'b00000, 5'b00101, 16'h0002}; #20;
    instr = {`OP_ORI, 5'b00000, 5'b00110, 16'h0002}; #20;
    //instr = {`OP_LB, 5'b00000, 5'b00001, 16'hFF0F}; #20;
    //instr = {`OP_LBU, 5'b00000, 5'b00011, 16'hFFFF}; #20;
    //instr = {`OP_JAL, 5'b00000, 5'b00101, 16'h7FFF}; #20;
    //instr = {`OP_SPECIAL, 5'b00101, 5'b00001, 5'b00001, 5'b00000, `FUNCT_ADDU}; #20;
    //instr = {`OP_SPECIAL, 5'b11111, 5'b00000, 5'b00010, 5'b00000, `FUNCT_JALR}; #20;
    //instr = {`OP_SPECIAL, 5'b00101, 5'b00001, 5'b00001, 5'b00000, `FUNCT_ADDU}; #20;
end*/

integer index = 0;
initial begin
#20;
forever begin
    instr = inst_mem[index];
    index = index + 1;
    #20;
    end
end
cpu_core cpu(
    .instruction(instr),
    .clk_50M(cpu_clk),
    .reset_btn(rst),
    .pc_out(pc),

    .mem_addr(mem_addr),
    .mem_wdata(mem_wdata),
    .mem_rdata(mem_rdata),
    .mem_ctrl_signal(mem_ctrl_signal),
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

logic[4:0] reg_addr;
logic[31:0] reg_data;

assign reg_addr = cpu.wb_reg_waddr;
assign reg_data = cpu.wb_reg_wdata;

task unittest(
	input [128*8 - 1:0] file_name,
	input check_cyc,
	input fpu
);

	integer i, fans, count, mem_index = 0;
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
	begin @(negedge cpu_clk);
	    count = count + 1;
	    if (cpu.wb_reg_waddr && cpu.wb_reg_wdata)
	    begin
		$sformat(out, "$%0d=0x%x", cpu.wb_reg_waddr, cpu.wb_reg_wdata);
		judge(fans, count, out, check_cyc);
		#20;
		end
	end
	$display("[OK] %0s\n", file_name);
endtask

initial begin
    unittest("inst_ori",0,0);
end

endmodule

	


