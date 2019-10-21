`include "common_defs.svh"

module cpu_core (
    input   logic       clk_50M,            //50MHz 时钟输入
    input   logic       clk_11M0592,        //11.0592MHz 时钟输入

    input   logic       clock_btn,          //BTN5手动时钟按钮开关，带消抖电路，按下时为1
    input   logic       reset_btn,          //BTN6手动复位按钮开关，带消抖电路，按下时为1
    input   logic       mem_stall,

    output  logic[15:0] leds,               //16位LED，输出时1点亮
    output  logic[7:0]  dpy0,               //数码管低位信号，包括小数点，输出1点亮
    output  logic[7:0]  dpy1,               //数码管高位信号，包括小数点，输出1点亮

    output  logic[`ADDR_WIDTH-1:0]      pc_out, mem_addr,
    output  logic[`DATA_WIDTH-1:0]      mem_wdata, reg_out,
    output  logic[4:0]                  mem_ctrl_signal,
    output  logic                       is_uart,
    input   logic[`DATA_WIDTH-1:0]      mem_rdata,
    input   logic[`INST_WIDTH-1:0]      instruction     //调试信号，用来在不实现访存模块时输入指令
);

assign leds = 16'b0101010101010101;

logic cpu_clk;
assign cpu_clk = clk_50M;

logic[`ADDR_WIDTH-1:0] if_pc, id_pc, new_pc;
logic[`INST_WIDTH-1:0] if_inst, id_inst;
logic[`REGID_WIDTH-1:0] raddr1, raddr2;
logic[`DATA_WIDTH-1:0] rdata1, rdata2;
assign if_inst = instruction;
assign pc_out = if_pc;

logic[`DATA_WIDTH-1:0] id_operand1, id_operand2, ex_operand1, ex_operand2;
alu_op_t id_alu_op, ex_alu_op;
logic[`REGID_WIDTH-1:0] id_reg_waddr, ex_reg_waddr, mem_reg_waddr, wb_reg_waddr;
logic id_reg_write_en, ex_reg_write_en, mem_reg_write_en, wb_reg_write_en;
logic pc_write_en;

logic[`DATA_WIDTH-1:0] ex_alu_result, mem_alu_result;
logic[`DATA_WIDTH-1:0] id_mem_data, ex_mem_data, mem_mem_data;

logic[`REGID_WIDTH-1:0] wb_waddr;
logic[`DATA_WIDTH-1:0] mem_reg_wdata, wb_reg_wdata;
logic[4:0] stall, id_mem_ctrl_signal, ex_mem_ctrl_signal, mem_mem_ctrl_signal;
//4: load_from_mem
//3: mem_data_write_en
//2: is_mem_data_read
//1: mem_byte_en
//0: mem_sign_ext

pc_reg pc_reg_r (
    .clk(cpu_clk),
    .rst(reset_btn),
    .stall(stall[4]),
    .mem_stall(mem_stall),
    .pc_out(if_pc),
    .write_en(pc_write_en),
    .pc_in(new_pc)
);

if_id_reg if_id_reg_r (
    .clk(cpu_clk),
    .rst(reset_btn),
    .stall(stall[3]),
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
    .reg_out(reg_out),
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
    .ex_mem_ctrl_signal(ex_mem_ctrl_signal),
    .mem_reg_waddr(mem_reg_waddr),
    .mem_reg_wdata(mem_alu_result),
    .mem_reg_write_en(mem_reg_write_en),
    .mem_mem_ctrl_signal(mem_mem_ctrl_signal),

    .mem_stall(mem_stall),

    .old_pc(id_pc),
    .is_branch(pc_write_en),
    .new_pc(new_pc),
    .load_from_mem(id_mem_ctrl_signal[4]),
    .mem_data_write_en(id_mem_ctrl_signal[3]),
    .is_mem_data_read(id_mem_ctrl_signal[2]),
    .mem_byte_en(id_mem_ctrl_signal[1]),
    .mem_sign_ext(id_mem_ctrl_signal[0]),
    .mem_data(id_mem_data),
    .stall(stall)
);

id_ex_reg id_ex_reg_r (
    .clk(cpu_clk),
    .rst(reset_btn),
    .stall(stall),
    .id_alu_op(id_alu_op),
    .id_operand1(id_operand1),
    .id_operand2(id_operand2),
    .id_reg_waddr(id_reg_waddr),
    .id_reg_write_en(id_reg_write_en),
    .id_mem_data(id_mem_data),
    .id_mem_ctrl_signal(id_mem_ctrl_signal),
    .ex_alu_op(ex_alu_op),
    .ex_operand1(ex_operand1),
    .ex_operand2(ex_operand2),
    .ex_reg_waddr(ex_reg_waddr),
    .ex_reg_write_en(ex_reg_write_en),
    .ex_mem_data(ex_mem_data),
    .ex_mem_ctrl_signal(ex_mem_ctrl_signal)
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
    .stall(stall[1]),
    .ex_alu_result(ex_alu_result),
    .ex_reg_waddr(ex_reg_waddr),
    .ex_reg_write_en(ex_reg_write_en),
    .ex_mem_data(ex_mem_data),
    .ex_mem_ctrl_signal(ex_mem_ctrl_signal),
    .mem_alu_result(mem_alu_result),
    .mem_reg_waddr(mem_reg_waddr),
    .mem_reg_write_en(mem_reg_write_en),
    .mem_mem_data(mem_mem_data),
    .mem_mem_ctrl_signal(mem_mem_ctrl_signal)
);

assign mem_reg_wdata = mem_mem_ctrl_signal[4] ? mem_rdata : mem_alu_result;
assign mem_addr = mem_alu_result;
assign mem_ctrl_signal = mem_mem_ctrl_signal;
assign mem_wdata = mem_mem_data;

always @(*) begin
    if (mem_addr >= 32'hbfd003f8) begin
        is_uart <= 1'b1;
    end else begin
        is_uart <= 1'b0;
    end
end

mem_wb_reg mem_wb_reg_r (
    .clk(cpu_clk),
    .rst(reset_btn),
    .stall(stall[0]),
    .mem_reg_waddr(mem_reg_waddr),
    .mem_reg_wdata(mem_reg_wdata),
    .mem_reg_write_en(mem_reg_write_en),
    .wb_reg_waddr(wb_reg_waddr),
    .wb_reg_wdata(wb_reg_wdata),
    .wb_reg_write_en(wb_reg_write_en)
);

endmodule