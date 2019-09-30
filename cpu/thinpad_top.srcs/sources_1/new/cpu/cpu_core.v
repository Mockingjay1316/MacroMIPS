module cpu_core (
    input   wire        clk_50M,    //50M时钟

    output  wire[15:0]  leds,       //16位LED，输出时1点亮
    output  wire[7:0]   dpy0,       //数码管低位信号，包括小数点，输出1点亮
    output  wire[7:0]   dpy1,       //数码管高位信号，包括小数点，输出1点亮

    //BaseRAM信号
    inout   wire[31:0]  base_ram_data,      //BaseRAM数据，低8位与CPLD串口控制器共享
    output  wire[19:0]  base_ram_addr,      //BaseRAM地址
    output  wire[3:0]   base_ram_be_n,      //BaseRAM字节使能，低有效。如果不使用字节使能，请保持为0
    output  wire        base_ram_ce_n,      //BaseRAM片选，低有效
    output  wire        base_ram_oe_n,      //BaseRAM读使能，低有效
    output  wire        base_ram_we_n,      //BaseRAM写使能，低有效

    //ExtRAM信号
    inout   wire[31:0]  ext_ram_data,       //ExtRAM数据
    output  wire[19:0]  ext_ram_addr,       //ExtRAM地址
    output  wire[3:0]   ext_ram_be_n,       //ExtRAM字节使能，低有效。如果不使用字节使能，请保持为0
    output  wire        ext_ram_ce_n,       //ExtRAM片选，低有效
    output  wire        ext_ram_oe_n,       //ExtRAM读使能，低有效
    output  wire        ext_ram_we_n        //ExtRAM写使能，低有效
);

assign leds = 16'b0000111100001111;
assign dpy0 = 8'b00001111;
assign dpy1 = 8'b00001111;

// 不使用内存、串口时，禁用其使能信号
assign base_ram_ce_n = 1'b1;
assign base_ram_oe_n = 1'b1;
assign base_ram_we_n = 1'b1;

assign ext_ram_ce_n = 1'b1;
assign ext_ram_oe_n = 1'b1;
assign ext_ram_we_n = 1'b1;

endmodule