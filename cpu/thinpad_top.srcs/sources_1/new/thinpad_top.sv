`include "common_defs.svh"

module thinpad_top(
    input   wire       clk_50M,            //50MHz 时钟输入
    input   wire       clk_11M0592,        //11.0592MHz 时钟输入

    input   wire       clock_btn,          //BTN5手动时钟按钮�???关，带消抖电路，按下时为1
    input   wire       reset_btn,          //BTN6手动复位按钮�???关，带消抖电路，按下时为1

    input   wire[3:0]  touch_btn,          //BTN1~BTN4，按钮开关，按下时为1
    input   wire[31:0] dip_sw,             //32位拨码开关，拨到“ON”时�???1
    output  wire[15:0] leds,               //16位LED，输出时1点亮
    output  wire[7:0]  dpy0,               //数码管低位信号，包括小数点，输出1点亮
    output  wire[7:0]  dpy1,               //数码管高位信号，包括小数点，输出1点亮

    CPLD.master        CPLD,
    Sram.master        base_ram,
    Sram.master        ext_ram,

    //直连串口信号
    output  wire       txd,                //直连串口发�?�端
    input   wire       rxd,                //直连串口接收�???

    //Flash存储器信号，参�?? JS28F640 芯片手册
    output  wire[22:0] flash_a,            //Flash地址，a0仅在8bit模式有效�???16bit模式无意�???
    inout   wire[15:0] flash_d,            //Flash数据
    output  wire       flash_rp_n,         //Flash复位信号，低有效
    output  wire       flash_vpen,         //Flash写保护信号，低电平时不能擦除、烧�???
    output  wire       flash_ce_n,         //Flash片�?�信号，低有�???
    output  wire       flash_oe_n,         //Flash读使能信号，低有�???
    output  wire       flash_we_n,         //Flash写使能信号，低有�???
    output  wire       flash_byte_n,       //Flash 8bit模式选择，低有效。在使用flash�???16位模式时请设�???1

    //USB 控制器信号，参�?? SL811 芯片手册
    output  wire       sl811_a0,
    //inout  logic[7:0] sl811_d,            //USB数据线与网络控制器的dm9k_sd[7:0]共享
    output  wire       sl811_wr_n,
    output  wire       sl811_rd_n,
    output  wire       sl811_cs_n,
    output  wire       sl811_rst_n,
    output  wire       sl811_dack_n,
    input   wire       sl811_intrq,
    input   wire       sl811_drq_n,

    //网络控制器信号，参�?? DM9000A 芯片手册
    output  wire       dm9k_cmd,
    inout   wire[15:0] dm9k_sd,
    output  wire       dm9k_iow_n,
    output  wire       dm9k_ior_n,
    output  wire       dm9k_cs_n,
    output  wire       dm9k_pwrst_n,
    input   wire       dm9k_int,

    //图像输出信号
    output  wire[2:0]  video_red,          //红色像素�???3�???
    output  wire[2:0]  video_green,        //绿色像素�???3�???
    output  wire[1:0]  video_blue,         //蓝色像素�???2�???
    output  wire       video_hsync,        //行同步（水平同步）信�???
    output  wire       video_vsync,        //场同步（垂直同步）信�???
    output  wire       video_clk,          //像素时钟输出
    output  wire       video_de            //行数据有效信号，用于区分消隐�???
);

logic rst, peri_clk, bus_clk, main_clk;
logic[`INST_WIDTH-1:0] instr;
logic[`ADDR_WIDTH-1:0] pc, mem_addr;
logic[`DATA_WIDTH-1:0] mem_wdata, sram_rdata, uart_rdata, reg_out, mem_rdata;
logic[4:0] mem_ctrl_signal;
logic is_uart, mem_stall;
logic[5:0] hardware_int;

assign hardware_int = {3'b000, ext_uart_already_read_status^ext_uart_read_status, 2'b00};        //打开了硬件中�???


main_pll pll (
    .clk_in1(clk_50M),
    .clk_out1(bus_clk),
    .clk_out2(peri_clk),
    .clk_out3(main_clk),
    .locked(rst)
);

cpu_core cpu (
    .clk_50M(main_clk),
    .clk_11M0592(clk_11M0592),

    .clock_btn(clock_btn),
    .reset_btn(reset_btn | ~rst),
    .mem_stall(mem_stall),

    .leds(leds),
    .dpy0(dpy0),
    .dpy1(dpy1),

    .hardware_int,
    .pc_out(pc),
    .mem_addr(mem_addr),
    .mem_wdata(mem_wdata),
    .reg_out(reg_out),
    .mem_rdata(mem_rdata),
    .mem_ctrl_signal(mem_ctrl_signal),
    .is_uart(is_uart),
    .instruction(instr)
);

sram_controller sram_ctrl (
    .main_clk(main_clk),
    .peri_clk(peri_clk),
    .rst(~rst),
    .pc(pc),
    .instr_read(instr),
    .data_write_en(mem_ctrl_signal[3]),
    .load_from_mem(mem_ctrl_signal[4]),
    .is_data_read(mem_ctrl_signal[2]),
    .mem_byte_en(mem_ctrl_signal[1]),
    .mem_sign_ext(mem_ctrl_signal[0]),
    .data_addr(mem_addr),
    .data_write(mem_wdata),
    .data_read(sram_rdata),
    .mem_stall(mem_stall),

    .base_ram_data(base_ram_data),
    .base_ram_addr(base_ram_addr),
    .base_ram_be_n(base_ram_be_n),
    .base_ram_ce_n(base_ram_ce_n),
    .base_ram_oe_n(base_ram_oe_n),
    .base_ram_we_n(base_ram_we_n),

    .ext_ram_data(ext_ram_data),
    .ext_ram_addr(ext_ram_addr),
    .ext_ram_be_n(ext_ram_be_n),
    .ext_ram_ce_n(ext_ram_ce_n),
    .ext_ram_oe_n(ext_ram_oe_n),
    .ext_ram_we_n(ext_ram_we_n)
);
/*
ila_0 ila (
    .clk(main_clk),
    .probe0(ext_uart_already_read_status),
    .probe1(ext_uart_read_status),
    .probe2(cpu.cp0_reg_r.Status),
    .probe3(uart_rdata),
    .probe4(ext_uart_wavai),
    .probe5(ext_uart_start),
    .probe6(ext_uart_tx),
    .probe7(mem_stall),
    .probe8(mem_ctrl_signal),
    .probe9(pc),
    .probe10(mem_addr),
    .probe11(reg_out),
    .probe12(instr)
);
*/
assign mem_rdata = is_uart ? uart_rdata : sram_rdata;

//直连串口接收发送演示，从直连串口收到的数据再发送出去
uart_controller uart_ctrl(
    .main_clk(main_clk),
    .peri_clk(peri_clk),
    .rst(~rst),
    .reset_btn(reset_btn),
    .rxd(rxd),
    .txd(txd),
    .mem_wdata(mem_wdata),
    .mem_addr(mem_addr),
    .mem_ctrl_signal(mem_ctrl_signal)
);

//直连串口接收发�?�演示，从直连串口收到的数据再发送出�???
logic[7:0] ext_uart_rx;
logic[7:0] ext_uart_buffer, ext_uart_tx;
logic ext_uart_ready, ext_uart_busy, ext_uart_clear;
logic ext_uart_start, ext_uart_wavai, ext_uart_ravai, ext_uart_read_status, ext_uart_already_read_status;
uart_rstate_t uart_rstate;



endmodule
