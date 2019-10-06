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
    output  logic       ext_ram_we_n        //ExtRAM写使能，低有效
);

assign leds = 16'b0101010101010101;

endmodule