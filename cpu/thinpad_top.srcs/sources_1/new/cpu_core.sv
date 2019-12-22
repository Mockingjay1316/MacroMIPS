`include "common_defs.svh"

module cpu_core (
    input   logic       clk_50M,            //50MHz 时钟输入
    input   logic       clk_11M0592,        //11.0592MHz 时钟输入

    input   logic       clock_btn,          //BTN5手动时钟按钮开关，带消抖电路，按下时为1
    input   logic       reset_btn,          //BTN6手动复位按钮开关，带消抖电路，按下时为1
    input   logic       mem_stall, data_not_ready,

    output  logic[15:0] leds,               //16位LED，输出时1点亮
    output  logic[7:0]  dpy0,               //数码管低位信号，包括小数点，输出1点亮
    output  logic[7:0]  dpy1,               //数码管高位信号，包括小数点，输出1点亮

    output  logic[`ADDR_WIDTH-1:0]      pc_out, mem_addr,
    output  logic[`DATA_WIDTH-1:0]      mem_wdata, reg_out,
    output  logic[4:0]                  mem_ctrl_signal,
    output  logic                       is_uart,
    input   logic[5:0]                  hardware_int,               //硬件中断
    input   logic[`DATA_WIDTH-1:0]      mem_rdata,
    input   logic[`INST_WIDTH-1:0]      instruction     //调试信号，用来在不实现访存模块时输入指令
);

assign leds = 16'b0101010101010101;

logic cpu_clk;
assign cpu_clk = clk_50M;

logic[`ADDR_WIDTH-1:0] if_pc, id_pc, new_pc;
logic[`INST_WIDTH-1:0] if_inst, id_inst;
logic[`REGID_WIDTH-1:0] raddr1, raddr2, cp0_raddr;
logic[2:0] cp0_rsel;
logic[7:0] excep_code;
logic[`DATA_WIDTH-1:0] rdata1, rdata2, cp0_rdata;
logic[`DATA_WIDTH-1:0] hi_out, lo_out;
logic[31:0] index;
logic from_random, tlb_write_en;
assign index = mem_pipeline_data.tlb_write_random ? cp0_reg_r.Random : cp0_reg_r.Index;
assign if_inst = (if_excep_info.tlb_pc_miss | mem_excep_info.is_eret) ? 32'h00000000 : instruction;

logic if_after_branch, id_after_branch, is_excep, is_eret, is_tlb_refill;

logic[`DATA_WIDTH-1:0] id_operand1, id_operand2, ex_operand1, ex_operand2;
alu_op_t id_alu_op, ex_alu_op;
logic[`REGID_WIDTH-1:0] id_reg_waddr, ex_reg_waddr, mem_reg_waddr, wb_reg_waddr;
logic id_reg_write_en, ex_reg_write_en, mem_reg_write_en, mem_mem_reg_write_en, wb_reg_write_en;
logic[`REGID_WIDTH-1:0] id_cp0_waddr, ex_cp0_waddr, mem_cp0_waddr, wb_cp0_waddr;
logic[2:0] id_cp0_wsel, ex_cp0_wsel, mem_cp0_wsel, wb_cp0_wsel;
logic id_cp0_write_en, ex_cp0_write_en, mem_cp0_write_en, wb_cp0_write_en;
logic pc_write_en, EPC_write_en, hw_int_o;
logic[`DATA_WIDTH-1:0] EPC_in, EPC_out;

cp0_op_t ex_cp0_op, mem_cp0_op, wb_cp0_op;
hilo_op_t id_hilo_op, idex_hilo_op, ex_hilo_op, mem_hilo_op, wb_hilo_op;
assign ex_cp0_op = {ex_cp0_waddr, ex_cp0_wsel, ex_cp0_write_en, ex_operand1};
assign mem_cp0_op = {mem_cp0_waddr, mem_cp0_wsel, mem_cp0_write_en, mem_alu_result};
assign wb_cp0_op = {wb_cp0_waddr, wb_cp0_wsel, wb_cp0_write_en, wb_reg_wdata};
excep_info_t id_excep_info, ex_excep_info, mem_excep_info;
excep_info_t if_excep_info, ifid_excep_info;
pipeline_data_t id_pipeline_data, ex_pipeline_data, mem_pipeline_data, wb_pipeline_data;
logic[31:0] tlbp_index, BadVAddr;
tlb_entry_t tlb_rdata;

logic[`DATA_WIDTH-1:0] ex_alu_result, mem_alu_result;
logic[`DATA_WIDTH-1:0] id_mem_data, ex_mem_data, mem_mem_data;

logic[`REGID_WIDTH-1:0] wb_waddr;
logic[`DATA_WIDTH-1:0] mem_reg_wdata, wb_reg_wdata;
logic[4:0] stall, id_mem_ctrl_signal, ex_mem_ctrl_signal, mem_mem_ctrl_signal, flush;
//mem_ctrl_signal
//4 -> load_from_mem
//3 -> mem_data_write_en
//2 -> is_mem_data_read
//1 -> mem_byte_en
//0 -> mem_sign_ext
//flush
//3 -> if-id
//2 -> id-ex
//1 -> ex-mem

pc_reg pc_reg_r (
    .clk(cpu_clk),
    .rst(reset_btn),
    .stall(stall[4]),
    .mem_stall(mem_stall),
    .is_excep,
    .data_not_ready,
    .is_tlb_refill,
    .is_eret(mem_excep_info.is_eret),
    .epc(EPC_out),
    .ebase(cp0_reg_r.EBase),
    .pc_out(if_pc),
    .write_en(pc_write_en),
    .pc_in(new_pc)
);

assign if_excep_info.tlb_pc_miss = pc_mmu_result.miss | ~pc_mmu_result.valid;
assign if_excep_info.instr_valid = ~mem_stall;
if_id_reg if_id_reg_r (
    .clk(cpu_clk),
    .rst(reset_btn | flush[3] | is_eret),       //eret没有延迟槽，需要刷掉if-id寄存器
    .stall(stall[3] | mem_stall),
    .data_not_ready,
    .if_pc(if_pc),
    .id_pc(id_pc),
    .if_after_branch,
    .id_after_branch,
    .if_inst(if_inst),
    .id_inst(id_inst),
    .if_excep_info,
    .ifid_excep_info
);

reg_file reg_file_r (
    .clk(cpu_clk),
    .rst(reset_btn),
    .write_en(wb_reg_write_en),
    .raddr1(raddr1),
    .raddr2(raddr2),
    .waddr(wb_reg_waddr),
    .reg_out(reg_out),
    .rdata1(rdata1),
    .rdata2(rdata2),
    .wdata(wb_reg_wdata)
);

hilo_reg hilo_reg_r (
    .clk(cpu_clk),
    .rst(reset_btn),
    .hi_out,
    .lo_out,
    .hilo_op(wb_hilo_op)
);

cp0_reg cp0_reg_r (
    .clk(cpu_clk),
    .rst(reset_btn),
    .raddr(cp0_raddr),
    .rsel(cp0_rsel),
    .rdata(cp0_rdata),
    .EPC_write_en(is_excep),
    .is_mem_eret(mem_excep_info.is_eret),
    .EPC_in,
    .BadVAddr_in(BadVAddr),
    .EPC_out,
    .excep_code,
    .hw_int_o,
    .hardware_int,

    .tlbp(mem_pipeline_data.tlbp),
    .tlbr(mem_pipeline_data.tlbr),
    .tlbp_index,
    .tlb_rdata,

    .write_en(wb_cp0_write_en),
    .waddr(wb_cp0_waddr),
    .wsel(wb_cp0_wsel),
    .wdata(wb_reg_wdata)
);

control_unit control_unit_r (
    .instr(id_inst),
    .reg_rdata1(rdata1),
    .reg_rdata2(rdata2),
    .reg_raddr1(raddr1),
    .reg_raddr2(raddr2),
    .hi_out,
    .lo_out,
    .operand1(id_operand1),
    .operand2(id_operand2),
    .reg_waddr(id_reg_waddr),
    .reg_write_en(id_reg_write_en),
    .alu_op(id_alu_op),

    .cp0_waddr(id_cp0_waddr),
    .cp0_write_en(id_cp0_write_en),
    .cp0_wsel(id_cp0_wsel),
    .cp0_raddr,
    .cp0_rsel,
    .cp0_rdata,
    .cp0_EPC(EPC_out),

    .ex_alu_result(ex_alu_result),
    .ex_reg_waddr(ex_reg_waddr),
    .ex_reg_write_en(ex_reg_write_en),
    .ex_mem_ctrl_signal(ex_mem_ctrl_signal),
    .mem_reg_waddr(mem_reg_waddr),
    .mem_reg_wdata(mem_alu_result),
    .mem_reg_write_en(mem_reg_write_en),
    .mem_mem_ctrl_signal(mem_mem_ctrl_signal),

    .mem_stall(mem_stall),
    .is_eret,                                       //指示是否遇到eret指令
    .from_random,
    .tlb_write_en,
    .ex_cp0_op,
    .mem_cp0_op,                                    //cp0旁通
    .ifid_excep_info,

    .old_pc(id_pc),
    .is_branch(pc_write_en),
    .after_branch(id_after_branch),
    .is_branch_op(if_after_branch),
    .new_pc(new_pc),

    .id_excep_info,
    .id_hilo_op,
    .ex_hilo_op,                                    //HILO旁通
    .mem_hilo_op,
    .wb_hilo_op,

    .load_from_mem(id_mem_ctrl_signal[4]),
    .mem_data_write_en(id_mem_ctrl_signal[3]),
    .is_mem_data_read(id_mem_ctrl_signal[2]),
    .mem_byte_en(id_mem_ctrl_signal[1]),
    .mem_sign_ext(id_mem_ctrl_signal[0]),
    .mem_data(id_mem_data),
    .id_pipeline_data,
    .stall(stall)
);

id_ex_reg id_ex_reg_r (
    .clk(cpu_clk),
    .rst(reset_btn | flush[2]),
    .stall(stall),
    .data_not_ready,
    .id_alu_op(id_alu_op),
    .id_operand1(id_operand1),
    .id_operand2(id_operand2),
    .id_reg_waddr(id_reg_waddr),
    .id_reg_write_en(id_reg_write_en),
    .id_mem_data(id_mem_data),
    .id_cp0_waddr,
    .id_cp0_write_en,
    .id_cp0_wsel,
    .id_excep_info,
    .id_hilo_op,
    .id_mem_ctrl_signal(id_mem_ctrl_signal),
    .id_pipeline_data,
    .ex_alu_op(ex_alu_op),
    .ex_operand1(ex_operand1),
    .ex_operand2(ex_operand2),
    .ex_reg_waddr(ex_reg_waddr),
    .ex_reg_write_en(ex_reg_write_en),
    .ex_mem_data(ex_mem_data),
    .ex_cp0_waddr,
    .ex_cp0_write_en,
    .ex_cp0_wsel,
    .ex_excep_info,
    .idex_hilo_op,
    .ex_mem_ctrl_signal(ex_mem_ctrl_signal),
    .ex_pipeline_data
);

alu_core alu_core_r (
    .alu_op(ex_alu_op),
    .operand1(ex_operand1),
    .operand2(ex_operand2),
    .idex_hilo_op,
    .ex_hilo_op,
    .alu_result(ex_alu_result)
);

ex_mem_reg ex_mem_reg_r (
    .clk(cpu_clk),
    .rst(reset_btn | flush[1]),
    .stall(stall[1]),
    .data_not_ready,
    .ex_alu_result(ex_alu_result),
    .ex_reg_waddr(ex_reg_waddr),
    .ex_reg_write_en(ex_reg_write_en),
    .ex_mem_data(ex_mem_data),
    .ex_cp0_waddr,
    .ex_cp0_write_en,
    .ex_cp0_wsel,
    .ex_excep_info,
    .ex_hilo_op,
    .ex_pipeline_data,
    .ex_mem_ctrl_signal(ex_mem_ctrl_signal),
    .mem_alu_result(mem_alu_result),
    .mem_reg_waddr(mem_reg_waddr),
    .mem_reg_write_en(mem_mem_reg_write_en),
    .mem_mem_data(mem_mem_data),
    .mem_cp0_waddr,
    .mem_cp0_write_en,
    .mem_cp0_wsel,
    .mem_excep_info,
    .mem_hilo_op,
    .mem_pipeline_data,
    .mem_mem_ctrl_signal(mem_mem_ctrl_signal)
);

excep_handler excep_handler_r (
    .mem_excep_info,
    .mem_pipeline_data,
    .Status(cp0_reg_r.Status),
    .pc_mmu_result,
    .data_mmu_result,
    .BadVAddr,
    .mem_mem_ctrl_signal,
    .is_tlb_refill,
    .EPC_out(EPC_in),
    .is_excep,
    .excep_code,
    .hardware_int(hw_int_o),
    .flush
);

mmu_res_t pc_mmu_result, data_mmu_result;

assign mem_addr = data_mmu_result.paddr;
assign pc_out = pc_mmu_result.paddr;

memory_unit mmu (
    .clk(cpu_clk),
    .rst(reset_btn),
    .pc_in(if_pc),
    .tlb_write_en(mem_pipeline_data.tlb_write_en),
    .index,
    .tlbp_index,
    .EntryHi(cp0_reg_r.EntryHi),
    .PageMask(cp0_reg_r.PageMask),
    .EntryLo1(cp0_reg_r.EntryLo1),
    .EntryLo0(cp0_reg_r.EntryLo0),
    .mem_addr_in(mem_alu_result),
    .pc_mmu_result,
    .data_mmu_result,
    .tlb_rdata
);

assign mem_reg_wdata = mem_mem_ctrl_signal[4] ? mem_rdata : mem_alu_result;
assign mem_ctrl_signal = (data_mmu_result.miss | ~data_mmu_result.valid) ? 5'b00000 : mem_mem_ctrl_signal;
assign mem_wdata = mem_mem_data;
assign mem_reg_write_en = ((data_mmu_result.miss | ~data_mmu_result.valid) & mem_mem_ctrl_signal[4]) ? 1'b0 : mem_mem_reg_write_en;

always @(*) begin
    if (mem_addr >= 32'hbfd003f8) begin
        is_uart <= 1'b1;
    end else begin
        is_uart <= 1'b0;
    end
end

mem_wb_reg mem_wb_reg_r (
    .clk(cpu_clk),
    .rst(reset_btn | is_excep),
    .stall(stall[0]),
    .mem_reg_waddr(mem_reg_waddr),
    .mem_reg_wdata(mem_reg_wdata),
    .mem_reg_write_en(mem_reg_write_en),
    .mem_cp0_waddr,
    .mem_cp0_write_en,
    .mem_cp0_wsel,
    .mem_hilo_op,
    .mem_pipeline_data,
    .wb_reg_waddr(wb_reg_waddr),
    .wb_reg_wdata(wb_reg_wdata),
    .wb_reg_write_en(wb_reg_write_en),
    .wb_cp0_waddr,
    .wb_cp0_write_en,
    .wb_cp0_wsel,
    .wb_hilo_op,
    .wb_pipeline_data
);

endmodule