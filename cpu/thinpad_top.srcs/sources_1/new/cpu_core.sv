`include "common_defs.svh"

module cpu_core (
    input   logic       clk_50M,            //50MHz 时钟输入
    input   logic       clk_11M0592,        //11.0592MHz 时钟输入

    input   logic       clock_btn,          //BTN5手动时钟按钮开关，带消抖电路，按下时为1
    input   logic       reset_btn,          //BTN6手动复位按钮开关，带消抖电路，按下时为1

    output  logic[15:0] leds,               //16位LED，输出时1点亮
    output  logic[7:0]  dpy0,               //数码管低位信号，包括小数点，输出1点亮
    output  logic[7:0]  dpy1,               //数码管高位信号，包括小数点，输出1点亮

    //BaseRAM信号
    inout   logic[31:0] base_ram_data,      //BaseRAM数据，低8位与CPLD串口控制器共享
    output  logic[19:0] base_ram_addr,      //BaseRAM地址
    output  logic[3:0]  base_ram_be_n,      //BaseRAM字节使能，低有效。如果不使用字节使能，请保持为0
    output  logic       base_ram_ce_n,      //BaseRAM片选，低有效
    output  logic       base_ram_oe_n,      //BaseRAM读使能，低有效
    output  logic       base_ram_we_n,      //BaseRAM写使能，低有效

    //ExtRAM信号
    inout   logic[31:0] ext_ram_data,       //ExtRAM数据
    output  logic[19:0] ext_ram_addr,       //ExtRAM地址
    output  logic[3:0]  ext_ram_be_n,       //ExtRAM字节使能，低有效。如果不使用字节使能，请保持为0
    output  logic       ext_ram_ce_n,       //ExtRAM片选，低有效
    output  logic       ext_ram_oe_n,       //ExtRAM读使能，低有效
    output  logic       ext_ram_we_n,       //ExtRAM写使能，低有效

    input   logic[`INST_WIDTH-1:0]      instruction     //调试信号，用来在不实现访存模块时输入指令
);

assign leds = 16'b0101010101010101;

logic cpu_clk;
assign cpu_clk = clk_50M;

logic[`ADDR_WIDTH-1:0] if_pc, id_pc;
logic[`INST_WIDTH-1:0] if_inst, id_inst;
logic[`REGID_WIDTH-1:0] raddr1, raddr2;
logic[`DATA_WIDTH-1:0] rdata1, rdata2;
assign if_inst = instruction;

logic[`DATA_WIDTH-1:0] id_operand1, id_operand2, ex_operand1, ex_operand2;
alu_op_t id_alu_op, ex_alu_op;
logic[`REGID_WIDTH-1:0] id_reg_waddr, ex_reg_waddr, mem_reg_waddr, wb_reg_waddr;
logic id_reg_write_en, ex_reg_write_en, mem_reg_write_en, wb_reg_write_en;

logic[`DATA_WIDTH-1:0] ex_alu_result, mem_alu_result;

logic[`REGID_WIDTH-1:0] wb_waddr;
logic[`DATA_WIDTH-1:0] wb_reg_wdata;

pc_reg pc_reg_r (
    .clk(cpu_clk),
    .rst(reset_btn),
    .pc_out(if_pc)
);

if_id_reg if_id_reg_r (
    .clk(cpu_clk),
    .rst(reset_btn),
    .if_pc(if_pc),
    .id_pc(id_pc),
    .if_inst(if_inst),
    .id_inst(id_inst)
);

reg_file reg_file_r (
    .clk(cpu_clk),
    .rst(reset_btn),
    .write_en(wb_reg_write_en),
    .raddr1(raddr1),
    .raddr2(raddr2),
    .waddr(wb_reg_waddr),
    .rdata1(rdata1),
    .rdata2(rdata2),
    .wdata(wb_reg_wdata)
);

control_unit control_unit_r (
    .instr(id_inst),
    .reg_rdata1(rdata1),
    .reg_rdata2(rdata2),
    .reg_raddr1(raddr1),
    .reg_raddr2(raddr2),
    .operand1(id_operand1),
    .operand2(id_operand2),
    .reg_waddr(id_reg_waddr),
    .reg_write_en(id_reg_write_en),
    .alu_op(id_alu_op),

    .ex_alu_result(ex_alu_result),
    .ex_reg_waddr(ex_reg_waddr),
    .ex_reg_write_en(ex_reg_write_en),
    .mem_reg_waddr(mem_reg_waddr),
    .mem_reg_wdata(mem_alu_result),
    .mem_reg_write_en(mem_reg_write_en)
);

id_ex_reg id_ex_reg_r (
    .clk(cpu_clk),
    .rst(reset_btn),
    .id_alu_op(id_alu_op),
    .id_operand1(id_operand1),
    .id_operand2(id_operand2),
    .id_reg_waddr(id_reg_waddr),
    .id_reg_write_en(id_reg_write_en),
    .ex_alu_op(ex_alu_op),
    .ex_operand1(ex_operand1),
    .ex_operand2(ex_operand2),
    .ex_reg_waddr(ex_reg_waddr),
    .ex_reg_write_en(ex_reg_write_en)
);

alu_core alu_core_r (
    .alu_op(ex_alu_op),
    .operand1(ex_operand1),
    .operand2(ex_operand2),
    .alu_result(ex_alu_result)
);

ex_mem_reg ex_mem_reg_r (
    .clk(cpu_clk),
    .rst(reset_btn),
    .ex_alu_result(ex_alu_result),
    .ex_reg_waddr(ex_reg_waddr),
    .ex_reg_write_en(ex_reg_write_en),
    .mem_alu_result(mem_alu_result),
    .mem_reg_waddr(mem_reg_waddr),
    .mem_reg_write_en(mem_reg_write_en)
);

mem_wb_reg mem_wb_reg_r (
    .clk(cpu_clk),
    .rst(reset_btn),
    .mem_reg_waddr(mem_reg_waddr),
    .mem_reg_wdata(mem_alu_result),
    .mem_reg_write_en(mem_reg_write_en),
    .wb_reg_waddr(wb_reg_waddr),
    .wb_reg_wdata(wb_reg_wdata),
    .wb_reg_write_en(wb_reg_write_en)
);

endmodule