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

    UART.master        uart,

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
Clock clk;
assign clk.clk_50M = clk_50M;
assign clk.clk_11M0592 = clk_11M0592;
assign clk.reset_btn = reset_btn;
assign clk.rst= rst;
assign clk.peri_clk = peri_clk;
assign clk.bus_clk = bus_clk;
assign main_clk = main_clk;

main_pll pll (
    .clk_in1(clk_50M),
    .clk_out1(bus_clk),
    .clk_out2(peri_clk),
    .clk_out3(main_clk),
    .locked(rst)
);

Bus cpu_data_bus(.clk);
Bus cpu_inst_bus(.clk);

cpu_core cpu (
    .inst_bus(cpu_inst_bus.master),
    .data_bus(cpu_data_bus.master)
);

Bus sram_bus(.clk);
Bus sram_inst(.clk);
Bus cpld_bus(.clk);

data_bus data_bus_instance(
    .cpu(cpu_data_bus.slave),
    .sram(sram_bus.master)
);

inst_bus inst_bus_instance(
    .cpu(cpu_inst_bus.slave),
    .sram(sram_inst.master)
);

sram_controller sram_ctrl (
    .inst_bus(sram_bus.slave),
    .base_ram,
    .ext_ram,
    .cpld
);

uart_controller usrt_ctrl(
    .data_bus(data_bus.slave),
    .uart  
);


endmodule
